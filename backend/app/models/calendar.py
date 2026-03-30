from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CreateEventRequest(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    is_all_day: bool = False
    assigned_to: Optional[str] = None
    color: Optional[str] = None


class UpdateEventRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    is_all_day: Optional[bool] = None
    assigned_to: Optional[str] = None
    color: Optional[str] = None


class CalendarEventResponse(BaseModel):
    id: str
    household_id: str
    title: str
    description: Optional[str] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    is_all_day: bool
    assigned_to: Optional[str] = None
    color: Optional[str] = None
    created_by: str
    created_at: datetime
