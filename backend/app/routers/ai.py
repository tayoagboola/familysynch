"""
AI Router — /ai prefix
All endpoints require authentication + household membership.
Chat endpoint is rate limited to 30 requests/hour per user.
"""

from fastapi import APIRouter, Depends, Request
from slowapi import Limiter
from slowapi.util import get_remote_address

from app.core.dependencies import require_household
from app.schemas.ai import ChatRequest, MarkNudgeReadRequest, NudgeListResponse
from app.schemas.ai import ChatResponse
from app.schemas.common import MessageResponse, SuccessResponse
from app.services.ai_service import AIService

router = APIRouter(prefix="/ai", tags=["ai"])
limiter = Limiter(key_func=get_remote_address)


@router.post("/chat", response_model=SuccessResponse[ChatResponse])
@limiter.limit("30/hour")
async def chat(
    request: Request,
    body: ChatRequest,
    current_user: dict = Depends(require_household),
    service: AIService = Depends(AIService),
):
    """
    Send message to FamilyAI.
    Builds live family context → calls Claude API → returns reply.
    active_context controls which data scopes are injected.
    history provides conversation continuity (last N messages).
    Rate limited: 30 requests/hour per IP.
    """
    result = await service.chat(
        body, current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.get("/nudges", response_model=SuccessResponse[NudgeListResponse])
async def get_nudges(
    current_user: dict = Depends(require_household),
    service: AIService = Depends(AIService),
):
    """
    Get nudges for current user.
    Used by: Flutter FAB badge count, home screen nudge card.
    Excludes expired nudges automatically.
    """
    result = await service.get_nudges(
        current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.post("/nudges/read", response_model=MessageResponse)
async def mark_nudges_read(
    body: MarkNudgeReadRequest,
    current_user: dict = Depends(require_household),
    service: AIService = Depends(AIService),
):
    """
    Mark one or more nudges as read.
    Flutter calls this when user opens the AI panel or taps "Got it".
    """
    await service.mark_nudges_read(body, current_user["id"])
    return MessageResponse(message="Nudges marked as read")
