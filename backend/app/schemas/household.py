from pydantic import BaseModel
from typing import Optional, List
from enum import Enum


class MemberRole(str, Enum):
    parent = "parent"
    child = "child"


# ── Requests ──────────────────────────────────────────────────────────────────

class CreateHouseholdRequest(BaseModel):
    name: str                          # e.g. "The Agboola Family"


class JoinHouseholdRequest(BaseModel):
    invite_code: str                   # 8-char alphanumeric code


class UpdateHouseholdRequest(BaseModel):
    name: Optional[str] = None


class UpdateMemberRoleRequest(BaseModel):
    role: MemberRole                   # parent | child


# ── Responses ─────────────────────────────────────────────────────────────────

class MemberResponse(BaseModel):
    id: str
    full_name: str
    initials: str
    email: str
    avatar_url: Optional[str] = None
    role: MemberRole
    household_id: str
    joined_at: Optional[str] = None


class HouseholdResponse(BaseModel):
    id: str
    name: str
    invite_code: str
    streak_days: int
    member_count: int
    created_at: str


class HouseholdDetailResponse(BaseModel):
    household: HouseholdResponse
    members: List[MemberResponse]


class InviteLinkResponse(BaseModel):
    invite_code: str
    invite_url: str                    # deep link: familysync://join/<code>
