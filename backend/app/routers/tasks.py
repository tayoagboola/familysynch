from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, status

from ..auth import CurrentUser
from ..database import get_supabase
from ..models.task import CreateTaskRequest, TaskResponse, UpdateTaskRequest
from ..services.fcm_service import send_push_to_user

router = APIRouter(prefix="/tasks", tags=["tasks"])


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


@router.get("/{household_id}/tasks", response_model=list[TaskResponse])
def list_tasks(household_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = (
        db.table("tasks")
        .select("*")
        .eq("household_id", household_id)
        .order("created_at", desc=True)
        .execute()
    )
    return result.data or []


@router.post("/{household_id}/tasks", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(household_id: str, body: CreateTaskRequest, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = db.table("tasks").insert({
        "household_id": household_id,
        "title": body.title,
        "description": body.description,
        "due_date": body.due_date.isoformat() if body.due_date else None,
        "assigned_to": body.assigned_to,
        "points": body.points,
        "completed": False,
        "created_by": user["sub"],
    }).execute()

    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create task")

    task = result.data[0]

    if body.assigned_to and body.assigned_to != user["sub"]:
        member = (
            db.table("household_members")
            .select("fcm_token, display_name")
            .eq("user_id", body.assigned_to)
            .eq("household_id", household_id)
            .maybe_single()
            .execute()
        )
        if member.data and member.data.get("fcm_token"):
            send_push_to_user(
                token=member.data["fcm_token"],
                title="New task assigned",
                body=body.title,
            )

    return task


@router.patch("/{household_id}/tasks/{task_id}", response_model=TaskResponse)
def update_task(household_id: str, task_id: str, body: UpdateTaskRequest, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    existing = (
        db.table("tasks")
        .select("id")
        .eq("id", task_id)
        .eq("household_id", household_id)
        .maybe_single()
        .execute()
    )
    if not existing.data:
        raise HTTPException(status_code=404, detail="Task not found")

    updates = body.model_dump(exclude_none=True)
    if updates.get("completed") is True:
        updates["completed_at"] = datetime.now(timezone.utc).isoformat()
        updates["completed_by"] = user["sub"]
    if "due_date" in updates and updates["due_date"] is not None:
        updates["due_date"] = updates["due_date"].isoformat()

    result = db.table("tasks").update(updates).eq("id", task_id).execute()
    return result.data[0]


@router.delete("/{household_id}/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(household_id: str, task_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    existing = (
        db.table("tasks")
        .select("id")
        .eq("id", task_id)
        .eq("household_id", household_id)
        .maybe_single()
        .execute()
    )
    if not existing.data:
        raise HTTPException(status_code=404, detail="Task not found")

    db.table("tasks").delete().eq("id", task_id).execute()
