"""
Notification Router — /notifications prefix
Flutter uses this to register/unregister FCM tokens.
Actual push dispatch is internal — called by other services.
"""

from fastapi import APIRouter, Depends

from app.core.dependencies import require_household
from app.schemas.common import MessageResponse
from app.schemas.notifications import RegisterTokenRequest
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.post("/register", response_model=MessageResponse)
async def register_token(
    body: RegisterTokenRequest,
    current_user: dict = Depends(require_household),
    service: NotificationService = Depends(NotificationService),
):
    """
    Register FCM token for this device.
    Flutter calls this after login and whenever FCM token refreshes.
    Safe to call multiple times — upsert on (member_id, fcm_token).
    """
    await service.register_token(body, current_user["id"])
    return MessageResponse(message="Token registered")


@router.delete("/register", response_model=MessageResponse)
async def unregister_token(
    body: RegisterTokenRequest,
    current_user: dict = Depends(require_household),
    service: NotificationService = Depends(NotificationService),
):
    """
    Unregister FCM token on logout or app uninstall.
    Flutter calls this before logout.
    """
    await service.unregister_token(body.fcm_token, current_user["id"])
    return MessageResponse(message="Token unregistered")
