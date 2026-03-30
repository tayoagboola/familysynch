from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CreateTaskRequest(BaseModel):
    title: str
    description: Optional[str] = None
    due_date: Optional[datetime] = None
    assigned_to: Optional[str] = None
    points: int = 0


class UpdateTaskRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[datetime] = None
    assigned_to: Optional[str] = None
    points: Optional[int] = None
    completed: Optional[bool] = None


class TaskResponse(BaseModel):
    id: str
    household_id: str
    title: str
    description: Optional[str] = None
    due_date: Optional[datetime] = None
    assigned_to: Optional[str] = None
    points: int
    completed: bool
    completed_at: Optional[datetime] = None
    completed_by: Optional[str] = None
    created_by: str
    created_at: datetime
