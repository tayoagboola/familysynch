from pydantic import BaseModel
from typing import Optional, List
from datetime import date
from enum import Enum


class TaskPriority(str, Enum):
    urgent = "urgent"
    normal = "normal"
    low    = "low"


# ── Requests ──────────────────────────────────────────────────────────────────

class CreateTaskRequest(BaseModel):
    title: str
    assigned_member_id: str
    due_date: Optional[date] = None
    priority: TaskPriority = TaskPriority.normal
    description: Optional[str] = None
    kid_points_value: int = 10          # XP awarded on completion if child


class UpdateTaskRequest(BaseModel):
    title: Optional[str] = None
    assigned_member_id: Optional[str] = None
    due_date: Optional[date] = None
    priority: Optional[TaskPriority] = None
    description: Optional[str] = None
    kid_points_value: Optional[int] = None


class CreateSubtaskRequest(BaseModel):
    title: str


class UpdateSubtaskRequest(BaseModel):
    title: Optional[str] = None
    is_completed: Optional[bool] = None


# ── Responses ─────────────────────────────────────────────────────────────────

class SubtaskResponse(BaseModel):
    id: str
    task_id: str
    title: str
    is_completed: bool


class AssignedMemberResponse(BaseModel):
    id: str
    full_name: str
    initials: str
    avatar_url: Optional[str] = None
    role: str


class TaskResponse(BaseModel):
    id: str
    household_id: str
    title: str
    description: Optional[str] = None
    assigned_member_id: str
    assigned_member: Optional[AssignedMemberResponse] = None
    due_date: Optional[str] = None
    priority: TaskPriority
    is_completed: bool
    completed_at: Optional[str] = None
    kid_points_value: int
    created_by: str
    created_at: str
    subtasks: List[SubtaskResponse] = []


class TaskListResponse(BaseModel):
    tasks: List[TaskResponse]
    total: int
    pending: int
    completed: int
