from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CreateHouseholdRequest(BaseModel):
    name: str
    emoji: str


class HouseholdResponse(BaseModel):
    id: str
    name: str
    emoji: str
    invite_code: str
    created_by: str
    created_at: datetime


class HouseholdMemberResponse(BaseModel):
    id: str
    household_id: str
    user_id: str
    display_name: str
    avatar_url: Optional[str] = None
    color: str
    role: str
    joined_at: datetime


class InviteLinkResponse(BaseModel):
    token: str
    expires_at: datetime


class AcceptInviteRequest(BaseModel):
    token: str
    display_name: str
