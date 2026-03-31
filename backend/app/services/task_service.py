"""
Task Service

Rules:
- Tasks belong to a household — only members can see/modify them
- assigned_member_id must belong to the same household
- On complete: if assigned member is a child → call KidService.award_xp()
- On complete: set is_completed=True + completed_at=now()
- On uncomplete: set is_completed=False + completed_at=None
- Subtasks cascade delete when parent task is deleted
- Every mutation broadcasts via ws_manager to all Flutter clients
- Import kid_service inside method to avoid circular imports
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from fastapi import Depends
from supabase import Client

from app.core.exceptions import FamilySyncException
from app.core.websocket_manager import ws_manager
from app.db.supabase_client import get_supabase
from app.schemas.tasks import (
    AssignedMemberResponse,
    CreateSubtaskRequest,
    CreateTaskRequest,
    SubtaskResponse,
    TaskListResponse,
    TaskResponse,
    UpdateSubtaskRequest,
    UpdateTaskRequest,
)


class TaskService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Create Task ───────────────────────────────────────────────────────────

    async def create_task(
        self,
        body: CreateTaskRequest,
        user_id: str,
        household_id: str,
    ) -> TaskResponse:
        """
        1. Validate assigned_member_id belongs to household
        2. Insert task row
        3. Broadcast tasks:task_added to all household WebSocket clients
        4. Return full task with assigned member profile
        """
        await self._validate_member(body.assigned_member_id, household_id)

        task_id = str(uuid.uuid4())
        self.db.table("tasks").insert({
            "id": task_id,
            "household_id": household_id,
            "title": body.title,
            "description": body.description,
            "assigned_member_id": body.assigned_member_id,
            "due_date": body.due_date.isoformat() if body.due_date else None,
            "priority": body.priority.value,
            "is_completed": False,
            "kid_points_value": body.kid_points_value,
            "created_by": user_id,
        }).execute()

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_added", task.model_dump()
        )
        return task

    # ── Get Tasks ─────────────────────────────────────────────────────────────

    async def get_tasks(
        self,
        household_id: str,
        member_id: Optional[str] = None,
        is_completed: Optional[bool] = None,
        priority: Optional[str] = None,
        due_date: Optional[str] = None,
    ) -> TaskListResponse:
        """
        Fetch tasks with optional filters.
        Used by: task board, home screen today tasks, kid mode.
        """
        query = self.db.table("tasks").select(
            "*, profiles!tasks_assigned_member_id_fkey"
            "(id, full_name, initials, avatar_url, role),"
            "subtasks(*)"
        ).eq("household_id", household_id)

        if member_id:
            query = query.eq("assigned_member_id", member_id)
        if is_completed is not None:
            query = query.eq("is_completed", is_completed)
        if priority:
            query = query.eq("priority", priority)
        if due_date:
            query = query.eq("due_date", due_date)

        result = query.order("is_completed").order(
            "priority", desc=True
        ).order("created_at").execute()

        tasks = [self._format_task(t) for t in result.data]
        pending   = sum(1 for t in tasks if not t.is_completed)
        completed = sum(1 for t in tasks if t.is_completed)

        return TaskListResponse(
            tasks=tasks,
            total=len(tasks),
            pending=pending,
            completed=completed,
        )

    # ── Get Single Task ───────────────────────────────────────────────────────

    async def get_task(self, task_id: str, household_id: str) -> TaskResponse:
        """Fetch a single task with subtasks and assigned member."""
        result = self.db.table("tasks").select(
            "*, profiles!tasks_assigned_member_id_fkey"
            "(id, full_name, initials, avatar_url, role),"
            "subtasks(*)"
        ).eq("id", task_id).eq("household_id", household_id).single().execute()

        if not result.data:
            raise FamilySyncException(404, "Task not found")

        return self._format_task(result.data)

    # ── Update Task ───────────────────────────────────────────────────────────

    async def update_task(
        self,
        task_id: str,
        household_id: str,
        body: UpdateTaskRequest,
    ) -> TaskResponse:
        """Update task fields. Broadcasts tasks:task_updated."""
        existing = self.db.table("tasks").select("id").eq(
            "id", task_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Task not found")

        if body.assigned_member_id:
            await self._validate_member(body.assigned_member_id, household_id)

        update_data = {}
        if body.title is not None:
            update_data["title"] = body.title
        if body.assigned_member_id is not None:
            update_data["assigned_member_id"] = body.assigned_member_id
        if body.due_date is not None:
            update_data["due_date"] = body.due_date.isoformat()
        if body.priority is not None:
            update_data["priority"] = body.priority.value
        if body.description is not None:
            update_data["description"] = body.description
        if body.kid_points_value is not None:
            update_data["kid_points_value"] = body.kid_points_value

        if update_data:
            self.db.table("tasks").update(update_data).eq("id", task_id).execute()

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_updated", task.model_dump()
        )
        return task

    # ── Complete Task ─────────────────────────────────────────────────────────

    async def complete_task(
        self,
        task_id: str,
        household_id: str,
        user_id: str,
    ) -> TaskResponse:
        """
        Mark task complete.
        If assigned to a child → award XP via KidService.
        Broadcasts tasks:task_completed.
        """
        task_result = self.db.table("tasks").select(
            "*, profiles!tasks_assigned_member_id_fkey(role)"
        ).eq("id", task_id).eq("household_id", household_id).single().execute()

        if not task_result.data:
            raise FamilySyncException(404, "Task not found")

        task_data = task_result.data
        if task_data["is_completed"]:
            raise FamilySyncException(400, "Task is already completed")

        self.db.table("tasks").update({
            "is_completed": True,
            "completed_at": datetime.now(timezone.utc).isoformat(),
        }).eq("id", task_id).execute()

        # Award XP if assigned to a child — imported inline to avoid circular imports
        assigned_profile = task_data.get("profiles") or {}
        if assigned_profile.get("role") == "child":
            from app.services.kid_service import KidService  # noqa: PLC0415
            kid_service = KidService(self.db)
            await kid_service.award_xp(
                member_id=task_data["assigned_member_id"],
                points=task_data.get("kid_points_value", 10),
                household_id=household_id,
            )

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_completed", task.model_dump()
        )
        return task

    # ── Uncomplete Task ───────────────────────────────────────────────────────

    async def uncomplete_task(
        self, task_id: str, household_id: str
    ) -> TaskResponse:
        """Undo task completion. Broadcasts tasks:task_updated."""
        existing = self.db.table("tasks").select("id").eq(
            "id", task_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Task not found")

        self.db.table("tasks").update({
            "is_completed": False,
            "completed_at": None,
        }).eq("id", task_id).execute()

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_updated", task.model_dump()
        )
        return task

    # ── Delete Task ───────────────────────────────────────────────────────────

    async def delete_task(self, task_id: str, household_id: str) -> None:
        """Delete task. Subtasks cascade delete via FK."""
        existing = self.db.table("tasks").select("id").eq(
            "id", task_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Task not found")

        self.db.table("tasks").delete().eq("id", task_id).execute()
        await ws_manager.broadcast(
            household_id, "tasks:task_deleted", {"task_id": task_id}
        )

    # ── Subtasks ──────────────────────────────────────────────────────────────

    async def create_subtask(
        self, task_id: str, household_id: str, body: CreateSubtaskRequest
    ) -> SubtaskResponse:
        """Add a subtask. Broadcasts tasks:task_updated with full task."""
        await self._verify_task(task_id, household_id)

        subtask_id = str(uuid.uuid4())
        result = self.db.table("subtasks").insert({
            "id": subtask_id,
            "task_id": task_id,
            "title": body.title,
            "is_completed": False,
        }).execute()

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_updated", task.model_dump()
        )
        return SubtaskResponse(**result.data[0])

    async def update_subtask(
        self,
        task_id: str,
        subtask_id: str,
        household_id: str,
        body: UpdateSubtaskRequest,
    ) -> SubtaskResponse:
        """Toggle subtask or rename it. Broadcasts tasks:task_updated."""
        await self._verify_task(task_id, household_id)

        update_data = {}
        if body.title is not None:
            update_data["title"] = body.title
        if body.is_completed is not None:
            update_data["is_completed"] = body.is_completed

        result = self.db.table("subtasks").update(update_data).eq(
            "id", subtask_id
        ).eq("task_id", task_id).execute()

        if not result.data:
            raise FamilySyncException(404, "Subtask not found")

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_updated", task.model_dump()
        )
        return SubtaskResponse(**result.data[0])

    async def delete_subtask(
        self, task_id: str, subtask_id: str, household_id: str
    ) -> None:
        """Delete subtask. Broadcasts tasks:task_updated."""
        await self._verify_task(task_id, household_id)

        self.db.table("subtasks").delete().eq(
            "id", subtask_id
        ).eq("task_id", task_id).execute()

        task = await self._get_task_with_details(task_id)
        await ws_manager.broadcast(
            household_id, "tasks:task_updated", task.model_dump()
        )

    # ── Private Helpers ───────────────────────────────────────────────────────

    async def _validate_member(self, member_id: str, household_id: str) -> None:
        result = self.db.table("profiles").select("id").eq(
            "id", member_id
        ).eq("household_id", household_id).execute()
        if not result.data:
            raise FamilySyncException(
                400, "Assigned member does not belong to this household"
            )

    async def _verify_task(self, task_id: str, household_id: str) -> None:
        existing = self.db.table("tasks").select("id").eq(
            "id", task_id
        ).eq("household_id", household_id).execute()
        if not existing.data:
            raise FamilySyncException(404, "Task not found")

    async def _get_task_with_details(self, task_id: str) -> TaskResponse:
        result = self.db.table("tasks").select(
            "*, profiles!tasks_assigned_member_id_fkey"
            "(id, full_name, initials, avatar_url, role),"
            "subtasks(*)"
        ).eq("id", task_id).single().execute()
        return self._format_task(result.data)

    def _format_task(self, t: dict) -> TaskResponse:
        profile = t.get("profiles") or {}
        assigned_member = AssignedMemberResponse(
            id=profile.get("id", ""),
            full_name=profile.get("full_name", ""),
            initials=profile.get("initials", ""),
            avatar_url=profile.get("avatar_url"),
            role=profile.get("role", "parent"),
        ) if profile else None

        subtasks = [SubtaskResponse(**s) for s in t.get("subtasks", [])]

        return TaskResponse(
            id=t["id"],
            household_id=t["household_id"],
            title=t["title"],
            description=t.get("description"),
            assigned_member_id=t["assigned_member_id"],
            assigned_member=assigned_member,
            due_date=t.get("due_date"),
            priority=t.get("priority", "normal"),
            is_completed=t.get("is_completed", False),
            completed_at=t.get("completed_at"),
            kid_points_value=t.get("kid_points_value", 10),
            created_by=t["created_by"],
            created_at=t.get("created_at", ""),
            subtasks=subtasks,
        )
