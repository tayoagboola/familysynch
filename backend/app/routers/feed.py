from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional

from ..auth import CurrentUser
from ..database import get_supabase

router = APIRouter(prefix="/feed", tags=["feed"])


class CreatePostRequest(BaseModel):
    content: str
    image_url: Optional[str] = None


class FeedPostResponse(BaseModel):
    id: str
    household_id: str
    content: str
    image_url: Optional[str] = None
    author_id: str
    created_at: str


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


@router.get("/{household_id}/posts", response_model=list[FeedPostResponse])
def list_posts(household_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = (
        db.table("feed_posts")
        .select("*")
        .eq("household_id", household_id)
        .order("created_at", desc=True)
        .limit(50)
        .execute()
    )
    return result.data or []


@router.post("/{household_id}/posts", response_model=FeedPostResponse, status_code=status.HTTP_201_CREATED)
def create_post(household_id: str, body: CreatePostRequest, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = db.table("feed_posts").insert({
        "household_id": household_id,
        "content": body.content,
        "image_url": body.image_url,
        "author_id": user["sub"],
    }).execute()

    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create post")
    return result.data[0]


@router.delete("/{household_id}/posts/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(household_id: str, post_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    existing = (
        db.table("feed_posts")
        .select("id, author_id")
        .eq("id", post_id)
        .eq("household_id", household_id)
        .maybe_single()
        .execute()
    )
    if not existing.data:
        raise HTTPException(status_code=404, detail="Post not found")
    if existing.data["author_id"] != user["sub"]:
        raise HTTPException(status_code=403, detail="Cannot delete another member's post")

    db.table("feed_posts").delete().eq("id", post_id).execute()
