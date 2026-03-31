"""
Auth Router — /auth prefix
All endpoints are public (no auth required) except /me and /logout.
Rate limited: 10 requests/minute per IP on login, register, and OAuth.
"""

from fastapi import APIRouter, Depends, Request
from slowapi import Limiter
from slowapi.util import get_remote_address

from app.core.dependencies import get_current_user
from app.schemas.auth import (
    AppleAuthRequest,
    AuthResponse,
    GoogleAuthRequest,
    LoginRequest,
    RefreshTokenRequest,
    TokenRefreshResponse,
    UserProfileResponse,
    RegisterRequest,
)
from app.schemas.common import MessageResponse, SuccessResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])
limiter = Limiter(key_func=get_remote_address)


@router.post("/register", response_model=SuccessResponse[AuthResponse])
@limiter.limit("10/minute")
async def register(
    request: Request,
    body: RegisterRequest,
    service: AuthService = Depends(AuthService),
):
    """
    Register new user with email + password.
    Returns JWT access token + refresh token + user profile.
    """
    result = await service.register(body)
    return SuccessResponse(data=result)


@router.post("/login", response_model=SuccessResponse[AuthResponse])
@limiter.limit("10/minute")
async def login(
    request: Request,
    body: LoginRequest,
    service: AuthService = Depends(AuthService),
):
    """
    Login with email + password.
    Returns JWT access token + refresh token + user profile.
    """
    result = await service.login(body)
    return SuccessResponse(data=result)


@router.post("/google", response_model=SuccessResponse[AuthResponse])
@limiter.limit("10/minute")
async def google_auth(
    request: Request,
    body: GoogleAuthRequest,
    service: AuthService = Depends(AuthService),
):
    """
    Authenticate with Google ID token (from Flutter google_sign_in).
    Creates account on first login. Returns JWT tokens.
    """
    result = await service.google_auth(body)
    return SuccessResponse(data=result)


@router.post("/apple", response_model=SuccessResponse[AuthResponse])
@limiter.limit("10/minute")
async def apple_auth(
    request: Request,
    body: AppleAuthRequest,
    service: AuthService = Depends(AuthService),
):
    """
    Authenticate with Apple identity token (from Flutter sign_in_with_apple).
    full_name only provided on first login — stored then.
    Returns JWT tokens.
    """
    result = await service.apple_auth(body)
    return SuccessResponse(data=result)


@router.post("/refresh", response_model=SuccessResponse[TokenRefreshResponse])
async def refresh_token(
    body: RefreshTokenRequest,
    service: AuthService = Depends(AuthService),
):
    """
    Exchange a refresh token for a new access token.
    Call this when Flutter receives a 401 response.
    """
    result = await service.refresh_token(body.refresh_token)
    return SuccessResponse(data=result)


@router.post("/logout", response_model=MessageResponse)
async def logout(current_user: dict = Depends(get_current_user)):
    """
    Logout endpoint. JWT is stateless so the client discards the token.
    Future: add token blocklist for true server-side invalidation.
    """
    return MessageResponse(message="Logged out successfully")


@router.get("/me", response_model=SuccessResponse[UserProfileResponse])
async def get_me(
    current_user: dict = Depends(get_current_user),
    service: AuthService = Depends(AuthService),
):
    """
    Get the current authenticated user's profile.
    Flutter calls this on app start to restore session state.
    """
    profile = await service.get_me(current_user["id"])
    return SuccessResponse(data=profile)
