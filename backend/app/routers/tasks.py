"""
Task Router — /tasks prefix
All endpoints require authentication + household membership.
WebSocket broadcasts happen inside the service layer on every mutation.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query

from app.core.dependencies import require_household
from app.schemas.common import MessageResponse, SuccessResponse
from app.schemas.tasks import (
    CreateSubtaskRequest,
    CreateTaskRequest,
    SubtaskResponse,
    TaskListResponse,
    TaskResponse,
    UpdateSubtaskRequest,
    UpdateTaskRequest,
)
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.get("", response_model=SuccessResponse[TaskListResponse])
async def get_tasks(
    member_id: Optional[str] = Query(None, description="Filter by assigned member ID"),
    is_completed: Optional[bool] = Query(None, description="Filter by completion state"),
    priority: Optional[str] = Query(None, description="urgent | normal | low"),
    due_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """
    Get tasks with optional filters.
    Used by: task board, home today tasks, kid mode task list.
    """
    result = await service.get_tasks(
        current_user["household_id"],
        member_id, is_completed, priority, due_date,
    )
    return SuccessResponse(data=result)


@router.get("/{task_id}", response_model=SuccessResponse[TaskResponse])
async def get_task(
    task_id: str,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Get single task with subtasks and assigned member details."""
    result = await service.get_task(task_id, current_user["household_id"])
    return SuccessResponse(data=result)


@router.post("", response_model=SuccessResponse[TaskResponse])
async def create_task(
    body: CreateTaskRequest,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Create task. Broadcasts tasks:task_added via WebSocket."""
    result = await service.create_task(
        body, current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.put("/{task_id}", response_model=SuccessResponse[TaskResponse])
async def update_task(
    task_id: str,
    body: UpdateTaskRequest,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Update task fields. Broadcasts tasks:task_updated via WebSocket."""
    result = await service.update_task(
        task_id, current_user["household_id"], body
    )
    return SuccessResponse(data=result)


@router.post("/{task_id}/complete", response_model=SuccessResponse[TaskResponse])
async def complete_task(
    task_id: str,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """
    Complete a task.
    Awards XP to the assigned member if they are a child.
    Broadcasts tasks:task_completed via WebSocket.
    """
    result = await service.complete_task(
        task_id, current_user["household_id"], current_user["id"]
    )
    return SuccessResponse(data=result)


@router.post("/{task_id}/uncomplete", response_model=SuccessResponse[TaskResponse])
async def uncomplete_task(
    task_id: str,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Undo task completion. Broadcasts tasks:task_updated via WebSocket."""
    result = await service.uncomplete_task(
        task_id, current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.delete("/{task_id}", response_model=MessageResponse)
async def delete_task(
    task_id: str,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Delete task and cascade subtasks. Broadcasts tasks:task_deleted via WebSocket."""
    await service.delete_task(task_id, current_user["household_id"])
    return MessageResponse(message="Task deleted successfully")


@router.post("/{task_id}/subtasks", response_model=SuccessResponse[SubtaskResponse])
async def create_subtask(
    task_id: str,
    body: CreateSubtaskRequest,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Add a subtask to a task."""
    result = await service.create_subtask(
        task_id, current_user["household_id"], body
    )
    return SuccessResponse(data=result)


@router.put("/{task_id}/subtasks/{subtask_id}", response_model=SuccessResponse[SubtaskResponse])
async def update_subtask(
    task_id: str,
    subtask_id: str,
    body: UpdateSubtaskRequest,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Toggle subtask completion or rename it."""
    result = await service.update_subtask(
        task_id, subtask_id, current_user["household_id"], body
    )
    return SuccessResponse(data=result)


@router.delete("/{task_id}/subtasks/{subtask_id}", response_model=MessageResponse)
async def delete_subtask(
    task_id: str,
    subtask_id: str,
    current_user: dict = Depends(require_household),
    service: TaskService = Depends(TaskService),
):
    """Delete a subtask."""
    await service.delete_subtask(
        task_id, subtask_id, current_user["household_id"]
    )
    return MessageResponse(message="Subtask deleted")
