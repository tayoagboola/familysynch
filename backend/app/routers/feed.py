"""
Feed Router — /feed prefix
All endpoints require authentication + household membership.
WebSocket broadcasts happen inside service layer on every mutation.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query

from app.core.dependencies import require_household
from app.schemas.common import MessageResponse, SuccessResponse
from app.schemas.feed import (
    CreatePostRequest,
    FeedResponse,
    PostResponse,
    ReactRequest,
)
from app.services.feed_service import FeedService

router = APIRouter(prefix="/feed", tags=["feed"])


@router.get("", response_model=SuccessResponse[FeedResponse])
async def get_feed(
    type: Optional[str] = Query(None, description="message|announcement|achievement|update"),
    cursor: Optional[str] = Query(None, description="created_at of last post for next page"),
    limit: int = Query(20, ge=1, le=50),
    current_user: dict = Depends(require_household),
    service: FeedService = Depends(FeedService),
):
    """
    Paginated feed. Newest first.
    Pass cursor to load older posts (infinite scroll).
    reactions include reacted_by_me based on current user.
    """
    result = await service.get_feed(
        current_user["household_id"],
        current_user["id"],
        post_type=type,
        cursor=cursor,
        limit=limit,
    )
    return SuccessResponse(data=result)


@router.post("", response_model=SuccessResponse[PostResponse])
async def create_post(
    body: CreatePostRequest,
    current_user: dict = Depends(require_household),
    service: FeedService = Depends(FeedService),
):
    """
    Create post. Supports text, event shares, achievements.
    Broadcasts feed:post_added to all household WebSocket clients.
    """
    result = await service.create_post(
        body, current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.delete("/{post_id}", response_model=MessageResponse)
async def delete_post(
    post_id: str,
    current_user: dict = Depends(require_household),
    service: FeedService = Depends(FeedService),
):
    """
    Delete post. Author or parent only.
    Reactions cascade delete. Broadcasts feed:post_deleted.
    """
    await service.delete_post(
        post_id, current_user["household_id"], current_user["id"]
    )
    return MessageResponse(message="Post deleted")


@router.post("/{post_id}/react", response_model=SuccessResponse[PostResponse])
async def toggle_reaction(
    post_id: str,
    body: ReactRequest,
    current_user: dict = Depends(require_household),
    service: FeedService = Depends(FeedService),
):
    """
    Toggle emoji reaction. Already reacted → removes. Not reacted → adds.
    Broadcasts feed:reaction_added or feed:reaction_removed.
    """
    result = await service.toggle_reaction(
        post_id, current_user["household_id"], current_user["id"], body
    )
    return SuccessResponse(data=result)
