from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

from ..auth import CurrentUser
from ..database import get_supabase

router = APIRouter(prefix="/notifications", tags=["notifications"])


class RegisterTokenRequest(BaseModel):
    fcm_token: str


@router.post("/register-token", status_code=status.HTTP_204_NO_CONTENT)
def register_fcm_token(body: RegisterTokenRequest, user: CurrentUser):
    db = get_supabase()
    result = (
        db.table("household_members")
        .select("id")
        .eq("user_id", user["sub"])
        .maybe_single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="Member record not found")

    db.table("household_members").update({
        "fcm_token": body.fcm_token
    }).eq("user_id", user["sub"]).execute()
