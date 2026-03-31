from pydantic import BaseModel
from typing import Optional


# ── Requests ──────────────────────────────────────────────────────────────────

class RegisterTokenRequest(BaseModel):
    fcm_token: str
    device_platform: str = "android"    # android | ios


class SendNotificationRequest(BaseModel):
    """Internal use — called by other services."""
    member_id: str
    title: str
    body: str
    data: Optional[dict] = None         # extra payload for Flutter deep link


class SendHouseholdNotificationRequest(BaseModel):
    """Broadcast to all members of a household."""
    household_id: str
    title: str
    body: str
    data: Optional[dict] = None
    exclude_member_id: Optional[str] = None  # exclude the sender


# ── Responses ─────────────────────────────────────────────────────────────────

class NotificationSentResponse(BaseModel):
    sent: int                           # number of devices notified
    failed: int
