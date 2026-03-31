from pydantic import BaseModel
from typing import Optional, List
from enum import Enum


class PostType(str, Enum):
    message      = "message"
    announcement = "announcement"
    achievement  = "achievement"
    update       = "update"
    system       = "system"


# ── Requests ──────────────────────────────────────────────────────────────────

class CreatePostRequest(BaseModel):
    content: str
    type: PostType = PostType.message
    linked_event_id: Optional[str] = None   # for sharing a calendar event
    linked_task_id: Optional[str] = None    # for celebrating a task completion


class ReactRequest(BaseModel):
    emoji: str                               # any unicode emoji e.g. "🎉" "❤️"


# ── Responses ─────────────────────────────────────────────────────────────────

class AuthorResponse(BaseModel):
    id: str
    full_name: str
    initials: str
    avatar_url: Optional[str]


class ReactionSummary(BaseModel):
    emoji: str
    count: int
    reacted_by_me: bool                      # True if current user reacted


class LinkedEventResponse(BaseModel):
    id: str
    title: str
    start_time: str
    color: str


class LinkedTaskResponse(BaseModel):
    id: str
    title: str
    assigned_member_id: str


class PostResponse(BaseModel):
    id: str
    household_id: str
    author_id: Optional[str]
    author: Optional[AuthorResponse]
    content: str
    type: PostType
    linked_event: Optional[LinkedEventResponse]
    linked_task: Optional[LinkedTaskResponse]
    reactions: List[ReactionSummary] = []
    created_at: str


class FeedResponse(BaseModel):
    posts: List[PostResponse]
    total: int
    has_more: bool
    next_cursor: Optional[str]               # created_at of last post for pagination
