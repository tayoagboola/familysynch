"""
Auth Service — owns all authentication logic.

Responsibilities:
- Register new user: create in Supabase Auth + insert profile row
- Login: verify password against Supabase Auth, issue FastAPI JWT
- Google OAuth: verify Google ID token, upsert user, issue JWT
- Apple OAuth: verify Apple identity token, upsert user, issue JWT
- Refresh token: verify refresh JWT, issue new access token
- Get profile: fetch profile row by user ID

Supabase Auth is used as the credential store.
FastAPI owns JWT creation and verification.
"""

import uuid
from typing import Optional

import httpx
from fastapi import Depends
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from supabase import Client

from app.core.config import settings
from app.core.exceptions import FamilySyncException
from app.core.security import create_access_token, create_refresh_token, decode_token
from app.db.supabase_client import get_supabase
from app.schemas.auth import (
    AppleAuthRequest,
    AuthResponse,
    GoogleAuthRequest,
    LoginRequest,
    RegisterRequest,
    TokenRefreshResponse,
    UserProfileResponse,
)


def _compute_initials(full_name: str) -> str:
    """Extract initials from full name. 'Benjamin Agboola' → 'BA'"""
    parts = full_name.strip().split()
    if len(parts) >= 2:
        return f"{parts[0][0]}{parts[-1][0]}".upper()
    return full_name[:2].upper() if full_name else "?"


class AuthService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Register ──────────────────────────────────────────────────────────────

    async def register(self, body: RegisterRequest) -> AuthResponse:
        """
        1. Validate password length (min 8 chars)
        2. Check email not already registered in profiles table
        3. Create user in Supabase Auth (admin API via service role)
        4. Insert row into profiles table with initials + role = 'parent'
        5. Issue FastAPI access + refresh tokens
        6. Return AuthResponse
        """
        if len(body.password) < 8:
            raise FamilySyncException(400, "Password must be at least 8 characters")

        existing = self.db.table("profiles").select("id").eq("email", body.email).execute()
        if existing.data:
            raise FamilySyncException(409, "Email already registered")

        try:
            auth_response = self.db.auth.admin.create_user({
                "email": body.email,
                "password": body.password,
                "email_confirm": True,
            })
            user_id = auth_response.user.id
        except Exception as e:
            raise FamilySyncException(400, f"Failed to create user: {e}")

        initials = _compute_initials(body.full_name)
        self.db.table("profiles").insert({
            "id": user_id,
            "full_name": body.full_name,
            "email": body.email,
            "initials": initials,
            "role": "parent",
            "household_id": None,
        }).execute()

        access_token = create_access_token(user_id)
        refresh_token = create_refresh_token(user_id)

        created_at = ""
        if auth_response.user.created_at:
            created_at = auth_response.user.created_at.isoformat()

        profile = UserProfileResponse(
            id=user_id,
            full_name=body.full_name,
            email=body.email,
            initials=initials,
            avatar_url=None,
            household_id=None,
            role="parent",
            created_at=created_at,
        )
        return AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=profile,
        )

    # ── Login ─────────────────────────────────────────────────────────────────

    async def login(self, body: LoginRequest) -> AuthResponse:
        """
        1. Authenticate via Supabase Auth (email + password)
        2. Fetch profile row from profiles table
        3. Issue FastAPI JWT (includes household_id in payload)
        4. Return AuthResponse
        """
        try:
            self.db.auth.sign_in_with_password({
                "email": body.email,
                "password": body.password,
            })
        except Exception:
            raise FamilySyncException(401, "Invalid email or password")

        # Fetch our profile (Supabase Auth response doesn't have household_id)
        profile = await self._get_profile_by_email(body.email)

        access_token = create_access_token(profile.id, profile.household_id)
        refresh_token = create_refresh_token(profile.id)

        return AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=profile,
        )

    # ── Google OAuth ──────────────────────────────────────────────────────────

    async def google_auth(self, body: GoogleAuthRequest) -> AuthResponse:
        """
        1. Verify Google ID token using google-auth library
        2. Extract email + name + avatar from verified payload
        3. Upsert: if email exists → fetch profile; else → create user + profile
        4. Return AuthResponse
        """
        try:
            idinfo = google_id_token.verify_oauth2_token(
                body.id_token,
                google_requests.Request(),
            )
        except Exception:
            raise FamilySyncException(401, "Invalid Google token")

        email = idinfo["email"]
        full_name = idinfo.get("name", email.split("@")[0])
        avatar_url = idinfo.get("picture")

        return await self._oauth_upsert(email, full_name, avatar_url)

    # ── Apple OAuth ───────────────────────────────────────────────────────────

    async def apple_auth(self, body: AppleAuthRequest) -> AuthResponse:
        """
        1. Verify Apple identity token (JWT signed by Apple's public keys)
        2. Extract email + sub from payload
        3. Upsert user — full_name only available on first Apple login
        4. Return AuthResponse
        """
        import jwt as pyjwt
        from jwt.algorithms import RSAAlgorithm

        async with httpx.AsyncClient() as client:
            keys_resp = await client.get("https://appleid.apple.com/auth/keys")
            apple_keys = keys_resp.json()

        try:
            header = pyjwt.get_unverified_header(body.identity_token)
            kid = header["kid"]
            matching_key = next(
                (k for k in apple_keys["keys"] if k["kid"] == kid), None
            )
            if not matching_key:
                raise FamilySyncException(401, "Apple public key not found")

            public_key = RSAAlgorithm.from_jwk(matching_key)
            payload = pyjwt.decode(
                body.identity_token,
                public_key,
                algorithms=["RS256"],
                audience="com.familysync.app",
            )
        except FamilySyncException:
            raise
        except Exception as e:
            raise FamilySyncException(401, f"Invalid Apple token: {e}")

        email = payload.get("email", f"{payload['sub']}@privaterelay.appleid.com")
        full_name = body.full_name or email.split("@")[0]

        return await self._oauth_upsert(email, full_name, None)

    # ── Refresh Token ─────────────────────────────────────────────────────────

    async def refresh_token(self, refresh_token: str) -> TokenRefreshResponse:
        """
        1. Decode and verify the refresh token
        2. Check type == 'refresh'
        3. Fetch latest profile to get current household_id
        4. Issue new access token
        """
        try:
            payload = decode_token(refresh_token)
        except ValueError:
            raise FamilySyncException(401, "Invalid refresh token")

        if payload.get("type") != "refresh":
            raise FamilySyncException(401, "Not a refresh token")

        profile = await self._get_profile(payload["sub"])
        new_access_token = create_access_token(profile.id, profile.household_id)
        return TokenRefreshResponse(access_token=new_access_token)

    # ── Get Profile ───────────────────────────────────────────────────────────

    async def get_me(self, user_id: str) -> UserProfileResponse:
        """Fetch the current user's profile."""
        return await self._get_profile(user_id)

    # ── Private Helpers ───────────────────────────────────────────────────────

    async def _get_profile(self, user_id: str) -> UserProfileResponse:
        result = (
            self.db.table("profiles")
            .select("*")
            .eq("id", user_id)
            .single()
            .execute()
        )
        if not result.data:
            raise FamilySyncException(404, "User profile not found")
        return self._row_to_profile(result.data)

    async def _get_profile_by_email(self, email: str) -> UserProfileResponse:
        result = (
            self.db.table("profiles")
            .select("*")
            .eq("email", email)
            .single()
            .execute()
        )
        if not result.data:
            raise FamilySyncException(404, "User profile not found")
        return self._row_to_profile(result.data)

    def _row_to_profile(self, p: dict) -> UserProfileResponse:
        return UserProfileResponse(
            id=p["id"],
            full_name=p["full_name"],
            email=p["email"],
            initials=p.get("initials", ""),
            avatar_url=p.get("avatar_url"),
            household_id=p.get("household_id"),
            role=p.get("role", "parent"),
            created_at=p.get("created_at", ""),
        )

    async def _oauth_upsert(
        self,
        email: str,
        full_name: str,
        avatar_url: Optional[str],
    ) -> AuthResponse:
        """Shared upsert logic for Google + Apple OAuth."""
        existing = (
            self.db.table("profiles").select("*").eq("email", email).execute()
        )

        if existing.data:
            profile = self._row_to_profile(existing.data[0])
        else:
            temp_password = str(uuid.uuid4())
            try:
                auth_resp = self.db.auth.admin.create_user({
                    "email": email,
                    "password": temp_password,
                    "email_confirm": True,
                })
                user_id = auth_resp.user.id
            except Exception as e:
                raise FamilySyncException(400, f"Failed to create OAuth user: {e}")

            initials = _compute_initials(full_name)
            self.db.table("profiles").insert({
                "id": user_id,
                "full_name": full_name,
                "email": email,
                "initials": initials,
                "avatar_url": avatar_url,
                "role": "parent",
                "household_id": None,
            }).execute()

            profile = await self._get_profile(user_id)

        access_token = create_access_token(profile.id, profile.household_id)
        refresh_token = create_refresh_token(profile.id)

        return AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=profile,
        )
