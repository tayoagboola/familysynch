"""
Household Service

Rules:
- A user can only belong to ONE household at a time
- Creator is always assigned role = 'parent'
- Joining updates the user's household_id in profiles table
- After joining, new JWT tokens must be issued (now contains household_id)
- A parent cannot be removed if they are the only parent
- Invite codes never expire in MVP
"""

import random
import string
import uuid

from fastapi import Depends
from supabase import Client

from app.core.exceptions import FamilySyncException
from app.core.security import create_access_token, create_refresh_token
from app.db.supabase_client import get_supabase
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


def _generate_invite_code(length: int = 8) -> str:
    """Generate unique alphanumeric invite code e.g. 'A3X9KP2M'"""
    chars = string.ascii_uppercase + string.digits
    return "".join(random.choices(chars, k=length))


class HouseholdService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Create Household ──────────────────────────────────────────────────────

    async def create_household(
        self, body: CreateHouseholdRequest, user_id: str
    ) -> dict:
        """
        1. Check user does not already belong to a household
        2. Generate unique invite code
        3. Insert household row
        4. Update user profile: set household_id + role = 'parent'
        5. Issue new JWT tokens (now includes household_id)
        6. Return household + new tokens
        """
        profile = (
            self.db.table("profiles")
            .select("household_id")
            .eq("id", user_id)
            .single()
            .execute()
        )
        if profile.data.get("household_id"):
            raise FamilySyncException(409, "You already belong to a household")

        # Ensure invite code uniqueness
        invite_code = _generate_invite_code()
        while (
            self.db.table("households")
            .select("id")
            .eq("invite_code", invite_code)
            .execute()
            .data
        ):
            invite_code = _generate_invite_code()

        household_id = str(uuid.uuid4())
        household = (
            self.db.table("households")
            .insert({
                "id": household_id,
                "name": body.name,
                "invite_code": invite_code,
                "streak_days": 0,
            })
            .execute()
            .data[0]
        )

        self.db.table("profiles").update({
            "household_id": household_id,
            "role": "parent",
        }).eq("id", user_id).execute()

        access_token = create_access_token(user_id, household_id)
        refresh_token = create_refresh_token(user_id)

        return {
            "household": self._format_household(household, member_count=1),
            "access_token": access_token,
            "refresh_token": refresh_token,
        }

    # ── Join Household ────────────────────────────────────────────────────────

    async def join_household(
        self, body: JoinHouseholdRequest, user_id: str
    ) -> dict:
        """
        1. Check user does not already belong to a household
        2. Lookup household by invite_code
        3. Update user profile: set household_id + role = 'parent'
        4. Issue new JWT tokens
        5. Return household detail + new tokens
        """
        profile = (
            self.db.table("profiles")
            .select("household_id")
            .eq("id", user_id)
            .single()
            .execute()
        )
        if profile.data.get("household_id"):
            raise FamilySyncException(409, "You already belong to a household")

        household_result = (
            self.db.table("households")
            .select("*")
            .eq("invite_code", body.invite_code.upper())
            .execute()
        )
        if not household_result.data:
            raise FamilySyncException(404, "Invalid invite code")

        household = household_result.data[0]
        household_id = household["id"]

        self.db.table("profiles").update({
            "household_id": household_id,
            "role": "parent",
        }).eq("id", user_id).execute()

        access_token = create_access_token(user_id, household_id)
        refresh_token = create_refresh_token(user_id)
        detail = await self.get_household_detail(household_id)

        return {
            "household": detail,
            "access_token": access_token,
            "refresh_token": refresh_token,
        }

    # ── Get Household Detail ──────────────────────────────────────────────────

    async def get_household_detail(self, household_id: str) -> HouseholdDetailResponse:
        household_result = (
            self.db.table("households")
            .select("*")
            .eq("id", household_id)
            .single()
            .execute()
        )
        if not household_result.data:
            raise FamilySyncException(404, "Household not found")

        members_result = (
            self.db.table("profiles")
            .select("*")
            .eq("household_id", household_id)
            .execute()
        )

        members = [self._format_member(m) for m in members_result.data]
        household = self._format_household(household_result.data, len(members))
        return HouseholdDetailResponse(household=household, members=members)

    # ── Get Members ───────────────────────────────────────────────────────────

    async def get_members(self, household_id: str) -> list[MemberResponse]:
        result = (
            self.db.table("profiles")
            .select("*")
            .eq("household_id", household_id)
            .execute()
        )
        return [self._format_member(m) for m in result.data]

    # ── Update Household ──────────────────────────────────────────────────────

    async def update_household(
        self, household_id: str, body: UpdateHouseholdRequest
    ) -> HouseholdResponse:
        update_data = {k: v for k, v in body.model_dump().items() if v is not None}
        if not update_data:
            raise FamilySyncException(400, "No fields to update")

        result = (
            self.db.table("households")
            .update(update_data)
            .eq("id", household_id)
            .execute()
        )
        members = (
            self.db.table("profiles")
            .select("id")
            .eq("household_id", household_id)
            .execute()
        )
        return self._format_household(result.data[0], len(members.data))

    # ── Update Member Role ────────────────────────────────────────────────────

    async def update_member_role(
        self, household_id: str, member_id: str, body: UpdateMemberRoleRequest
    ) -> MemberResponse:
        member = (
            self.db.table("profiles")
            .select("*")
            .eq("id", member_id)
            .eq("household_id", household_id)
            .single()
            .execute()
        )
        if not member.data:
            raise FamilySyncException(404, "Member not found in this household")

        result = (
            self.db.table("profiles")
            .update({"role": body.role.value})
            .eq("id", member_id)
            .execute()
        )
        return self._format_member(result.data[0])

    # ── Remove Member ─────────────────────────────────────────────────────────

    async def remove_member(self, household_id: str, member_id: str) -> None:
        """
        Remove member from household.
        Cannot remove the last parent.
        """
        member = (
            self.db.table("profiles")
            .select("*")
            .eq("id", member_id)
            .eq("household_id", household_id)
            .single()
            .execute()
        )
        if not member.data:
            raise FamilySyncException(404, "Member not found")

        if member.data["role"] == "parent":
            parents = (
                self.db.table("profiles")
                .select("id")
                .eq("household_id", household_id)
                .eq("role", "parent")
                .execute()
            )
            if len(parents.data) <= 1:
                raise FamilySyncException(
                    400, "Cannot remove the only parent from the household"
                )

        self.db.table("profiles").update({
            "household_id": None,
            "role": "parent",
        }).eq("id", member_id).execute()

    # ── Regenerate Invite ─────────────────────────────────────────────────────

    async def regenerate_invite(self, household_id: str) -> InviteLinkResponse:
        new_code = _generate_invite_code()
        while (
            self.db.table("households")
            .select("id")
            .eq("invite_code", new_code)
            .execute()
            .data
        ):
            new_code = _generate_invite_code()

        self.db.table("households").update({
            "invite_code": new_code
        }).eq("id", household_id).execute()

        return InviteLinkResponse(
            invite_code=new_code,
            invite_url=f"familysync://join/{new_code}",
        )

    # ── Private Helpers ───────────────────────────────────────────────────────

    def _format_household(self, h: dict, member_count: int) -> HouseholdResponse:
        return HouseholdResponse(
            id=h["id"],
            name=h["name"],
            invite_code=h["invite_code"],
            streak_days=h.get("streak_days", 0),
            member_count=member_count,
            created_at=h.get("created_at", ""),
        )

    def _format_member(self, m: dict) -> MemberResponse:
        return MemberResponse(
            id=m["id"],
            full_name=m["full_name"],
            initials=m.get("initials", ""),
            email=m.get("email", ""),
            avatar_url=m.get("avatar_url"),
            role=m.get("role", "parent"),
            household_id=m.get("household_id", ""),
            joined_at=m.get("joined_at") or m.get("created_at"),
        )
