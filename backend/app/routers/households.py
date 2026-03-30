import secrets
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, HTTPException, status

from ..auth import CurrentUser
from ..database import get_supabase
from ..models.household import (
    AcceptInviteRequest,
    CreateHouseholdRequest,
    HouseholdMemberResponse,
    HouseholdResponse,
    InviteLinkResponse,
)

router = APIRouter(prefix="/households", tags=["households"])

_MEMBER_COLORS = [
    "#2E7D6B", "#1565C0", "#AD1457", "#E65100",
    "#6A1B9A", "#00838F", "#558B2F", "#4E342E",
]


def _next_color(household_id: str) -> str:
    db = get_supabase()
    result = (
        db.table("household_members")
        .select("color")
        .eq("household_id", household_id)
        .execute()
    )
    used = {r["color"] for r in (result.data or [])}
    for c in _MEMBER_COLORS:
        if c not in used:
            return c
    return _MEMBER_COLORS[len(result.data or []) % len(_MEMBER_COLORS)]


@router.post("", response_model=HouseholdResponse, status_code=status.HTTP_201_CREATED)
def create_household(body: CreateHouseholdRequest, user: CurrentUser):
    db = get_supabase()
    user_id: str = user["sub"]
    invite_code = secrets.token_urlsafe(8)

    result = (
        db.table("households")
        .insert({
            "name": body.name,
            "emoji": body.emoji,
            "invite_code": invite_code,
            "created_by": user_id,
        })
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to create household")

    household = result.data[0]

    db.table("household_members").insert({
        "household_id": household["id"],
        "user_id": user_id,
        "display_name": user.get("email", "").split("@")[0],
        "color": _MEMBER_COLORS[0],
        "role": "admin",
    }).execute()

    return household


@router.get("/me", response_model=HouseholdMemberResponse)
def get_my_membership(user: CurrentUser):
    db = get_supabase()
    result = (
        db.table("household_members")
        .select("*")
        .eq("user_id", user["sub"])
        .limit(1)
        .maybe_single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="Not a member of any household")
    return result.data


@router.get("/{household_id}/members", response_model=list[HouseholdMemberResponse])
def list_members(household_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = (
        db.table("household_members")
        .select("*")
        .eq("household_id", household_id)
        .execute()
    )
    return result.data or []


@router.post("/{household_id}/invite-link", response_model=InviteLinkResponse)
def generate_invite_link(household_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    token = secrets.token_urlsafe(32)
    expires_at = datetime.now(timezone.utc) + timedelta(days=7)

    db.table("invite_tokens").insert({
        "token": token,
        "household_id": household_id,
        "created_by": user["sub"],
        "expires_at": expires_at.isoformat(),
    }).execute()

    return {"token": token, "expires_at": expires_at}


@router.post("/accept-invite", response_model=HouseholdMemberResponse, status_code=status.HTTP_201_CREATED)
def accept_invite(body: AcceptInviteRequest, user: CurrentUser):
    db = get_supabase()

    token_row = (
        db.table("invite_tokens")
        .select("*")
        .eq("token", body.token)
        .maybe_single()
        .execute()
    )
    if not token_row.data:
        raise HTTPException(status_code=404, detail="Invalid invite token")

    invite = token_row.data
    if invite.get("used_at"):
        raise HTTPException(status_code=410, detail="Invite already used")

    expires_at = datetime.fromisoformat(invite["expires_at"])
    if expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=410, detail="Invite expired")

    household_id = invite["household_id"]
    color = _next_color(household_id)

    result = db.table("household_members").insert({
        "household_id": household_id,
        "user_id": user["sub"],
        "display_name": body.display_name,
        "color": color,
        "role": "parent",
    }).execute()

    db.table("invite_tokens").update({"used_at": datetime.now(timezone.utc).isoformat()}).eq("token", body.token).execute()

    return result.data[0]


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
