"""
Household Router — /household prefix
All endpoints require authentication.
/create and /join work before the user has a household (get_current_user only).
All others require require_household dependency.
"""

from fastapi import APIRouter, Depends

from app.core.dependencies import get_current_user, require_household
from app.schemas.common import MessageResponse, SuccessResponse
from app.schemas.household import (
    CreateHouseholdRequest,
    HouseholdDetailResponse,
    HouseholdResponse,
    InviteLinkResponse,
    JoinHouseholdRequest,
    MemberResponse,
    UpdateHouseholdRequest,
    UpdateMemberRoleRequest,
)
from app.services.household_service import HouseholdService

router = APIRouter(prefix="/household", tags=["household"])


@router.post("/create", response_model=SuccessResponse[dict])
async def create_household(
    body: CreateHouseholdRequest,
    current_user: dict = Depends(get_current_user),
    service: HouseholdService = Depends(HouseholdService),
):
    """
    Create a new household. Caller becomes first parent.
    Returns new access_token + refresh_token — Flutter MUST store these.
    The new tokens contain household_id, required for all subsequent calls.
    """
    result = await service.create_household(body, current_user["id"])
    return SuccessResponse(data=result)


@router.post("/join", response_model=SuccessResponse[dict])
async def join_household(
    body: JoinHouseholdRequest,
    current_user: dict = Depends(get_current_user),
    service: HouseholdService = Depends(HouseholdService),
):
    """
    Join existing household via 8-char invite code.
    Returns new access_token + refresh_token — Flutter MUST store these.
    """
    result = await service.join_household(body, current_user["id"])
    return SuccessResponse(data=result)


@router.get("/me", response_model=SuccessResponse[HouseholdDetailResponse])
async def get_my_household(
    current_user: dict = Depends(require_household),
    service: HouseholdService = Depends(HouseholdService),
):
    """Get current household with full member list."""
    result = await service.get_household_detail(current_user["household_id"])
    return SuccessResponse(data=result)


@router.get("/members", response_model=SuccessResponse[list[MemberResponse]])
async def get_members(
    current_user: dict = Depends(require_household),
    service: HouseholdService = Depends(HouseholdService),
):
    """
    Get all household members.
    Used for member filter chips across calendar, tasks, and feed screens.
    """
    result = await service.get_members(current_user["household_id"])
    return SuccessResponse(data=result)


@router.put("/me", response_model=SuccessResponse[HouseholdResponse])
async def update_household(
    body: UpdateHouseholdRequest,
    current_user: dict = Depends(require_household),
    service: HouseholdService = Depends(HouseholdService),
):
    """Update household name."""
    result = await service.update_household(current_user["household_id"], body)
    return SuccessResponse(data=result)


@router.put("/members/{member_id}/role", response_model=SuccessResponse[MemberResponse])
async def update_member_role(
    member_id: str,
    body: UpdateMemberRoleRequest,
    current_user: dict = Depends(require_household),
    service: HouseholdService = Depends(HouseholdService),
):
    """Promote or demote a member between parent and child roles."""
    result = await service.update_member_role(
        current_user["household_id"], member_id, body
    )
    return SuccessResponse(data=result)


@router.delete("/members/{member_id}", response_model=MessageResponse)
async def remove_member(
    member_id: str,
    current_user: dict = Depends(require_household),
    service: HouseholdService = Depends(HouseholdService),
):
    """
    Remove a member from the household (or leave it yourself).
    Cannot remove the last parent.
    """
    await service.remove_member(current_user["household_id"], member_id)
    return MessageResponse(message="Member removed successfully")


@router.post("/invite", response_model=SuccessResponse[InviteLinkResponse])
async def regenerate_invite(
    current_user: dict = Depends(require_household),
    service: HouseholdService = Depends(HouseholdService),
):
    """
    Generate a fresh invite code and deep link.
    Share via familysync://join/<code> or QR code on the settings screen.
    """
    result = await service.regenerate_invite(current_user["household_id"])
    return SuccessResponse(data=result)
