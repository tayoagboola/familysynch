from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum


class EventColor(str, Enum):
    orange = "orange"
    teal   = "teal"
    yellow = "yellow"
    purple = "purple"
    blue   = "blue"
    green  = "green"


# ── Requests ──────────────────────────────────────────────────────────────────

class CreateEventRequest(BaseModel):
    title: str
    start_time: datetime
    end_time: datetime
    location: Optional[str] = None
    color: EventColor = EventColor.orange
    member_ids: List[str] = []          # members to attach to this event


class UpdateEventRequest(BaseModel):
    title: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    location: Optional[str] = None
    color: Optional[EventColor] = None
    member_ids: Optional[List[str]] = None  # replaces full member list if provided


class AddEventMembersRequest(BaseModel):
    member_ids: List[str]


# ── Responses ─────────────────────────────────────────────────────────────────

class EventMemberResponse(BaseModel):
    member_id: str
    full_name: str
    initials: str
    avatar_url: Optional[str] = None


class EventResponse(BaseModel):
    id: str
    household_id: str
    title: str
    start_time: str
    end_time: str
    location: Optional[str] = None
    color: EventColor
    created_by: str
    created_at: str
    members: List[EventMemberResponse] = []


class EventListResponse(BaseModel):
    events: List[EventResponse]
    total: int
