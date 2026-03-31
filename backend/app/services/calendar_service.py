"""
Calendar Service

Rules:
- Events belong to a household — only household members can see/modify them
- start_time must be before end_time — enforced in service
- member_ids list may be empty (household-wide event with no specific assignees)
- Creator is always added to event_members even if not in member_ids
- On update, if member_ids is provided it replaces the entire list
- Deleting an event cascades to event_members via FK cascade in SQL
"""

import uuid
from typing import Optional

from fastapi import Depends
from supabase import Client

from app.core.exceptions import FamilySyncException
from app.db.supabase_client import get_supabase
from app.schemas.calendar import (
    AddEventMembersRequest,
    CreateEventRequest,
    EventListResponse,
    EventMemberResponse,
    EventResponse,
    UpdateEventRequest,
)


class CalendarService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Create Event ──────────────────────────────────────────────────────────

    async def create_event(
        self,
        body: CreateEventRequest,
        user_id: str,
        household_id: str,
    ) -> EventResponse:
        """
        1. Validate start_time < end_time
        2. Insert event row
        3. Insert event_members rows (creator always included)
        4. Return full event with members
        """
        if body.start_time >= body.end_time:
            raise FamilySyncException(400, "start_time must be before end_time")

        event_id = str(uuid.uuid4())
        self.db.table("events").insert({
            "id": event_id,
            "household_id": household_id,
            "title": body.title,
            "start_time": body.start_time.isoformat(),
            "end_time": body.end_time.isoformat(),
            "location": body.location,
            "color": body.color.value,
            "created_by": user_id,
        }).execute()

        # Creator always included in event_members
        member_ids = list(set([user_id] + body.member_ids))
        await self._upsert_event_members(event_id, member_ids)

        return await self._get_event_with_members(event_id)

    # ── Get Events (date range) ───────────────────────────────────────────────

    async def get_events(
        self,
        household_id: str,
        date_from: Optional[str] = None,
        date_to: Optional[str] = None,
        member_id: Optional[str] = None,
    ) -> EventListResponse:
        """
        Fetch events for the household within a date range.
        Used by: monthly calendar grid, home screen week strip.
        Optionally filter by member_id (applied in Python after fetch).
        """
        query = self.db.table("events").select(
            "*, event_members(member_id, profiles(full_name, initials, avatar_url))"
        ).eq("household_id", household_id)

        if date_from:
            query = query.gte("start_time", date_from)
        if date_to:
            query = query.lt("start_time", date_to)

        result = query.order("start_time").execute()
        events = result.data

        if member_id:
            events = [
                e for e in events
                if any(
                    em["member_id"] == member_id
                    for em in e.get("event_members", [])
                )
            ]

        formatted = [self._format_event(e) for e in events]
        return EventListResponse(events=formatted, total=len(formatted))

    # ── Get Day Events ────────────────────────────────────────────────────────

    async def get_day_events(
        self, household_id: str, date: str
    ) -> EventListResponse:
        """
        Fetch all events for a specific day (YYYY-MM-DD).
        Used by: calendar timeline view, home screen today events.
        """
        date_start = f"{date}T00:00:00+00:00"
        date_end   = f"{date}T23:59:59+00:00"

        result = self.db.table("events").select(
            "*, event_members(member_id, profiles(full_name, initials, avatar_url))"
        ).eq("household_id", household_id).gte(
            "start_time", date_start
        ).lte("start_time", date_end).order("start_time").execute()

        formatted = [self._format_event(e) for e in result.data]
        return EventListResponse(events=formatted, total=len(formatted))

    # ── Get Single Event ──────────────────────────────────────────────────────

    async def get_event(self, event_id: str, household_id: str) -> EventResponse:
        """Fetch a single event. Verifies it belongs to the household."""
        result = self.db.table("events").select(
            "*, event_members(member_id, profiles(full_name, initials, avatar_url))"
        ).eq("id", event_id).eq("household_id", household_id).single().execute()

        if not result.data:
            raise FamilySyncException(404, "Event not found")

        return self._format_event(result.data)

    # ── Update Event ──────────────────────────────────────────────────────────

    async def update_event(
        self,
        event_id: str,
        household_id: str,
        body: UpdateEventRequest,
    ) -> EventResponse:
        """
        Update event fields. If member_ids provided, replaces full member list.
        Validates start_time < end_time when both are being updated.
        """
        existing = self.db.table("events").select("id").eq(
            "id", event_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Event not found")

        update_data = {}
        if body.title is not None:
            update_data["title"] = body.title
        if body.start_time is not None:
            update_data["start_time"] = body.start_time.isoformat()
        if body.end_time is not None:
            update_data["end_time"] = body.end_time.isoformat()
        if body.location is not None:
            update_data["location"] = body.location
        if body.color is not None:
            update_data["color"] = body.color.value

        if "start_time" in update_data and "end_time" in update_data:
            if body.start_time >= body.end_time:
                raise FamilySyncException(400, "start_time must be before end_time")

        if update_data:
            self.db.table("events").update(update_data).eq("id", event_id).execute()

        if body.member_ids is not None:
            self.db.table("event_members").delete().eq("event_id", event_id).execute()
            await self._upsert_event_members(event_id, body.member_ids)

        return await self._get_event_with_members(event_id)

    # ── Delete Event ──────────────────────────────────────────────────────────

    async def delete_event(self, event_id: str, household_id: str) -> None:
        """Delete event. event_members cascade via FK on delete cascade."""
        existing = self.db.table("events").select("id").eq(
            "id", event_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Event not found")

        self.db.table("events").delete().eq("id", event_id).execute()

    # ── Add Members ───────────────────────────────────────────────────────────

    async def add_event_members(
        self, event_id: str, household_id: str, body: AddEventMembersRequest
    ) -> EventResponse:
        """Add additional members to an existing event (upsert — safe to call with existing IDs)."""
        existing = self.db.table("events").select("id").eq(
            "id", event_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Event not found")

        await self._upsert_event_members(event_id, body.member_ids)
        return await self._get_event_with_members(event_id)

    # ── Remove Event Member ───────────────────────────────────────────────────

    async def remove_event_member(
        self, event_id: str, household_id: str, member_id: str
    ) -> EventResponse:
        """Remove a single member from an event."""
        existing = self.db.table("events").select("id").eq(
            "id", event_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Event not found")

        self.db.table("event_members").delete().eq(
            "event_id", event_id
        ).eq("member_id", member_id).execute()

        return await self._get_event_with_members(event_id)

    # ── Private Helpers ───────────────────────────────────────────────────────

    async def _upsert_event_members(
        self, event_id: str, member_ids: list[str]
    ) -> None:
        if not member_ids:
            return
        rows = [
            {"id": str(uuid.uuid4()), "event_id": event_id, "member_id": mid}
            for mid in member_ids
        ]
        self.db.table("event_members").upsert(
            rows, on_conflict="event_id,member_id"
        ).execute()

    async def _get_event_with_members(self, event_id: str) -> EventResponse:
        result = self.db.table("events").select(
            "*, event_members(member_id, profiles(full_name, initials, avatar_url))"
        ).eq("id", event_id).single().execute()
        return self._format_event(result.data)

    def _format_event(self, e: dict) -> EventResponse:
        members = []
        for em in e.get("event_members", []):
            profile = em.get("profiles") or {}
            members.append(EventMemberResponse(
                member_id=em["member_id"],
                full_name=profile.get("full_name", ""),
                initials=profile.get("initials", ""),
                avatar_url=profile.get("avatar_url"),
            ))
        return EventResponse(
            id=e["id"],
            household_id=e["household_id"],
            title=e["title"],
            start_time=e["start_time"],
            end_time=e["end_time"],
            location=e.get("location"),
            color=e.get("color", "orange"),
            created_by=e["created_by"],
            created_at=e.get("created_at", ""),
            members=members,
        )
