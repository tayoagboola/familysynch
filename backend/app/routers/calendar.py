from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, HTTPException, Query, status

from ..auth import CurrentUser
from ..database import get_supabase
from ..models.calendar import (
    CalendarEventResponse,
    CreateEventRequest,
    UpdateEventRequest,
)

router = APIRouter(prefix="/calendar", tags=["calendar"])


def _assert_member(db, household_id: str, user_id: str):
    result = (
        db.table("household_members")
        .select("id")
        .eq("household_id", household_id)
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=403, detail="Not a member of this household")


@router.get("/{household_id}/events", response_model=list[CalendarEventResponse])
def list_events(
    household_id: str,
    user: CurrentUser,
    from_date: Optional[datetime] = Query(None),
    to_date: Optional[datetime] = Query(None),
):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    query = db.table("calendar_events").select("*").eq("household_id", household_id)
    if from_date:
        query = query.gte("start_time", from_date.isoformat())
    if to_date:
        query = query.lte("start_time", to_date.isoformat())

    result = query.order("start_time").execute()
    return result.data or []


@router.post("/{household_id}/events", response_model=CalendarEventResponse, status_code=status.HTTP_201_CREATED)
def create_event(household_id: str, body: CreateEventRequest, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = db.table("calendar_events").insert({
        "household_id": household_id,
        "title": body.title,
        "description": body.description,
        "start_time": body.start_time.isoformat(),
        "end_time": body.end_time.isoformat() if body.end_time else None,
        "is_all_day": body.is_all_day,
        "assigned_to": body.assigned_to,
        "color": body.color,
        "created_by": user["sub"],
    }).execute()

    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create event")
    return result.data[0]


@router.patch("/{household_id}/events/{event_id}", response_model=CalendarEventResponse)
def update_event(
    household_id: str,
    event_id: str,
    body: UpdateEventRequest,
    user: CurrentUser,
):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    existing = (
        db.table("calendar_events")
        .select("id")
        .eq("id", event_id)
        .eq("household_id", household_id)
        .maybe_single()
        .execute()
    )
    if not existing.data:
        raise HTTPException(status_code=404, detail="Event not found")

    updates = body.model_dump(exclude_none=True)
    if "start_time" in updates:
        updates["start_time"] = updates["start_time"].isoformat()
    if "end_time" in updates:
        updates["end_time"] = updates["end_time"].isoformat()

    result = (
        db.table("calendar_events")
        .update(updates)
        .eq("id", event_id)
        .execute()
    )
    return result.data[0]


@router.delete("/{household_id}/events/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event(household_id: str, event_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    existing = (
        db.table("calendar_events")
        .select("id, created_by")
        .eq("id", event_id)
        .eq("household_id", household_id)
        .maybe_single()
        .execute()
    )
    if not existing.data:
        raise HTTPException(status_code=404, detail="Event not found")

    db.table("calendar_events").delete().eq("id", event_id).execute()
