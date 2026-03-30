import json
import logging

import httpx

from ..config import settings

logger = logging.getLogger(__name__)


def _get_access_token() -> str | None:
    """Get OAuth2 access token for FCM HTTP v1 API using service account."""
    if not settings.fcm_service_account_json:
        return None
    try:
        import google.auth
        import google.auth.transport.requests
        from google.oauth2 import service_account

        sa_info = json.loads(settings.fcm_service_account_json)
        credentials = service_account.Credentials.from_service_account_info(
            sa_info,
            scopes=["https://www.googleapis.com/auth/firebase.messaging"],
        )
        credentials.refresh(google.auth.transport.requests.Request())
        return credentials.token
    except Exception as e:
        logger.warning("FCM token refresh failed: %s", e)
        return None


def send_push_to_user(token: str, title: str, body: str, data: dict | None = None) -> bool:
    if not settings.fcm_project_id:
        logger.debug("FCM not configured, skipping push notification")
        return False

    access_token = _get_access_token()
    if not access_token:
        return False

    url = f"https://fcm.googleapis.com/v1/projects/{settings.fcm_project_id}/messages:send"
    payload = {
        "message": {
            "token": token,
            "notification": {"title": title, "body": body},
            "data": data or {},
        }
    }

    try:
        response = httpx.post(
            url,
            json=payload,
            headers={"Authorization": f"Bearer {access_token}"},
            timeout=10,
        )
        response.raise_for_status()
        return True
    except httpx.HTTPError as e:
        logger.error("FCM send failed: %s", e)
        return False
