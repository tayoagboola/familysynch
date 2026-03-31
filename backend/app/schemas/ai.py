from pydantic import BaseModel
from typing import Optional, List
from enum import Enum


class ContextScope(str, Enum):
    calendar = "calendar"
    tasks    = "tasks"
    grocery  = "grocery"
    members  = "members"
    feed     = "feed"


class NudgeType(str, Enum):
    reminder    = "reminder"
    suggestion  = "suggestion"
    warning     = "warning"
    celebration = "celebration"


# ── Requests ──────────────────────────────────────────────────────────────────

class ChatMessage(BaseModel):
    role: str                           # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    message: str
    history: List[ChatMessage] = []     # last N messages for context
    active_context: List[ContextScope] = [
        ContextScope.calendar,
        ContextScope.tasks,
        ContextScope.grocery,
    ]


class MarkNudgeReadRequest(BaseModel):
    nudge_ids: List[str]                # mark multiple as read at once


# ── Responses ─────────────────────────────────────────────────────────────────

class ChatResponse(BaseModel):
    reply: str
    context_used: List[ContextScope]    # which data scopes were injected


class NudgeResponse(BaseModel):
    id: str
    title: str
    body: str
    type: NudgeType
    is_read: bool
    created_at: str
    expires_at: Optional[str]


class NudgeListResponse(BaseModel):
    nudges: List[NudgeResponse]
    unread_count: int
