from pydantic import BaseModel, EmailStr
from typing import Optional


# ── Requests ──────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str                    # min 8 chars — validated in service


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class GoogleAuthRequest(BaseModel):
    id_token: str                    # Google ID token from Flutter google_sign_in


class AppleAuthRequest(BaseModel):
    identity_token: str              # Apple identity token from Flutter sign_in_with_apple
    full_name: Optional[str] = None  # Only provided on first Apple login


class RefreshTokenRequest(BaseModel):
    refresh_token: str


# ── Responses ─────────────────────────────────────────────────────────────────

class UserProfileResponse(BaseModel):
    id: str
    full_name: str
    email: str
    initials: str
    avatar_url: Optional[str] = None
    household_id: Optional[str] = None
    role: str                        # parent | child
    created_at: str


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserProfileResponse


class TokenRefreshResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
