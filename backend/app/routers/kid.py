"""
Kid Router — /kid prefix
All endpoints require authentication + household membership.
award_xp is called internally by TaskService — no direct endpoint for it.
"""

from fastapi import APIRouter, Depends

from app.core.dependencies import require_household
from app.schemas.common import SuccessResponse
from app.schemas.kid import BadgeShelfResponse, KidProgressResponse
from app.services.kid_service import KidService

router = APIRouter(prefix="/kid", tags=["kid"])


@router.get("/{member_id}/progress", response_model=SuccessResponse[KidProgressResponse])
async def get_kid_progress(
    member_id: str,
    current_user: dict = Depends(require_household),
    service: KidService = Depends(KidService),
):
    """
    Get kid XP, level, and streak for Kid Mode home screen.
    Returns defaults if no tasks completed yet.
    Any household member can fetch any child's progress.
    """
    result = await service.get_progress(member_id)
    return SuccessResponse(data=result)


@router.get("/{member_id}/badges", response_model=SuccessResponse[BadgeShelfResponse])
async def get_kid_badges(
    member_id: str,
    current_user: dict = Depends(require_household),
    service: KidService = Depends(KidService),
):
    """
    Get all badges — earned (with earned_at) and locked.
    Used by: Kid Mode badge shelf, parent dashboard.
    """
    result = await service.get_badges(member_id)
    return SuccessResponse(data=result)
