"""
Calendar Router — /calendar prefix
All endpoints require authentication + household membership.
No WebSocket broadcasts — Flutter refetches after mutations.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query

from app.core.dependencies import require_household
from app.schemas.calendar import (
    AddEventMembersRequest,
    CreateEventRequest,
    EventListResponse,
    EventResponse,
    UpdateEventRequest,
)
from app.schemas.common import MessageResponse, SuccessResponse
from app.services.calendar_service import CalendarService

router = APIRouter(prefix="/calendar", tags=["calendar"])


@router.get("", response_model=SuccessResponse[EventListResponse])
async def get_events(
    date_from: Optional[str] = Query(None, description="ISO datetime e.g. 2026-03-01T00:00:00"),
    date_to: Optional[str] = Query(None, description="ISO datetime e.g. 2026-04-01T00:00:00"),
    member_id: Optional[str] = Query(None, description="Filter events by member ID"),
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """
    Get household events within a date range.
    Used by: monthly grid, home week strip, upcoming events section.
    """
    result = await service.get_events(
        current_user["household_id"], date_from, date_to, member_id
    )
    return SuccessResponse(data=result)


@router.get("/day", response_model=SuccessResponse[EventListResponse])
async def get_day_events(
    date: str = Query(..., description="Date in YYYY-MM-DD format"),
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """
    Get all events for a specific day ordered by start_time.
    Used by: calendar timeline view, home screen today panel.
    """
    result = await service.get_day_events(current_user["household_id"], date)
    return SuccessResponse(data=result)


@router.get("/{event_id}", response_model=SuccessResponse[EventResponse])
async def get_event(
    event_id: str,
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """Get a single event with full member details."""
    result = await service.get_event(event_id, current_user["household_id"])
    return SuccessResponse(data=result)


@router.post("", response_model=SuccessResponse[EventResponse])
async def create_event(
    body: CreateEventRequest,
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """
    Create a new calendar event.
    Creator is automatically added to members even if not in member_ids.
    """
    result = await service.create_event(
        body, current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.put("/{event_id}", response_model=SuccessResponse[EventResponse])
async def update_event(
    event_id: str,
    body: UpdateEventRequest,
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """
    Update event fields.
    Passing member_ids replaces the full member list.
    Omit member_ids to leave members unchanged.
    """
    result = await service.update_event(
        event_id, current_user["household_id"], body
    )
    return SuccessResponse(data=result)


@router.delete("/{event_id}", response_model=MessageResponse)
async def delete_event(
    event_id: str,
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """Delete event. Cascades to event_members automatically."""
    await service.delete_event(event_id, current_user["household_id"])
    return MessageResponse(message="Event deleted successfully")


@router.post("/{event_id}/members", response_model=SuccessResponse[EventResponse])
async def add_event_members(
    event_id: str,
    body: AddEventMembersRequest,
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """Add one or more members to an existing event."""
    result = await service.add_event_members(
        event_id, current_user["household_id"], body
    )
    return SuccessResponse(data=result)


@router.delete("/{event_id}/members/{member_id}", response_model=SuccessResponse[EventResponse])
async def remove_event_member(
    event_id: str,
    member_id: str,
    current_user: dict = Depends(require_household),
    service: CalendarService = Depends(CalendarService),
):
    """Remove a single member from an event."""
    result = await service.remove_event_member(
        event_id, current_user["household_id"], member_id
    )
    return SuccessResponse(data=result)
