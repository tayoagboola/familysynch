"""
Notification Service

Responsibilities:
- register_token(): save FCM token for a device when user logs in
- unregister_token(): remove token on logout or app uninstall
- send_to_member(): send push to all devices of a single member
- send_to_household(): broadcast push to all members of a household
- send_to_members(): send push to a list of member IDs

Called internally by:
- TaskService: notify assigned member of new task
- KidService: notify parents of kid level up / badge unlock
- JobsService: send daily nudge pushes
- FeedService: notify household of new post

Firebase Admin SDK handles the actual FCM dispatch.
Tokens are stored in a device_tokens table (not in profiles).
One member can have multiple tokens (multiple devices).

Rules:
- Invalid/expired tokens are silently removed from the table
- Never raise an exception if push fails — log and continue
- send_to_household excludes the triggering member by default
- data payload used by Flutter for deep link navigation
"""

import json
import logging

from fastapi import Depends
from supabase import Client

import firebase_admin
from firebase_admin import credentials, messaging

from app.core.config import settings
from app.db.supabase_client import get_supabase
from app.schemas.notifications import (
    NotificationSentResponse,
    RegisterTokenRequest,
)

logger = logging.getLogger(__name__)

_firebase_enabled = False

# ── Firebase Initialization ───────────────────────────────────────────────────

def _init_firebase():
    """Initialize Firebase Admin SDK from JSON credentials in env var."""
    global _firebase_enabled

    if firebase_admin._apps:
        _firebase_enabled = True
        return

    raw_credentials = settings.firebase_credentials_json.strip()
    if not raw_credentials:
        logger.warning(
            "Firebase credentials not configured; push notifications disabled."
        )
        return

    try:
        cred_dict = json.loads(raw_credentials)
        cred = credentials.Certificate(cred_dict)
        firebase_admin.initialize_app(cred)
        _firebase_enabled = True
    except (json.JSONDecodeError, ValueError, TypeError) as exc:
        logger.warning(
            "Invalid Firebase credentials; push notifications disabled: %s",
            exc,
        )

_init_firebase()


# ── Notification Templates ────────────────────────────────────────────────────

class NotificationTemplates:
    """Reusable notification templates for consistent messaging."""

    @staticmethod
    def new_task(task_title: str, assigned_by: str) -> dict:
        return {
            "title": "New task assigned 📋",
            "body": f"{assigned_by} added: {task_title}",
        }

    @staticmethod
    def task_completed(task_title: str, completed_by: str) -> dict:
        return {
            "title": "Task completed ✅",
            "body": f"{completed_by} finished: {task_title}",
        }

    @staticmethod
    def grocery_added(item_name: str, added_by: str) -> dict:
        return {
            "title": "Grocery list updated 🛒",
            "body": f"{added_by} added {item_name}",
        }

    @staticmethod
    def new_feed_post(author_name: str, preview: str) -> dict:
        return {
            "title": f"{author_name} posted 💬",
            "body": preview[:80] + ("..." if len(preview) > 80 else ""),
        }

    @staticmethod
    def kid_level_up(kid_name: str, new_level: int, level_name: str) -> dict:
        return {
            "title": "Level up! 🎉",
            "body": f"{kid_name} reached Level {new_level} — {level_name}!",
        }

    @staticmethod
    def badge_unlocked(kid_name: str, badge_name: str, emoji: str) -> dict:
        return {
            "title": f"{emoji} New badge unlocked!",
            "body": f"{kid_name} earned the '{badge_name}' badge!",
        }

    @staticmethod
    def daily_nudge(title: str, body: str) -> dict:
        return {"title": title, "body": body}

    @staticmethod
    def new_event(event_title: str, start_time: str) -> dict:
        return {
            "title": "New event added 📅",
            "body": f"{event_title} · {start_time}",
        }


class NotificationService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Register Token ────────────────────────────────────────────────────────

    async def register_token(
        self, body: RegisterTokenRequest, user_id: str
    ) -> None:
        """
        Save FCM token for this device.
        Upsert on (member_id, fcm_token) — safe to call multiple times.
        Called by Flutter after login and on FCM token refresh.
        """
        self.db.table("device_tokens").upsert({
            "member_id": user_id,
            "fcm_token": body.fcm_token,
            "device_platform": body.device_platform,
        }, on_conflict="member_id,fcm_token").execute()

    # ── Unregister Token ──────────────────────────────────────────────────────

    async def unregister_token(
        self, fcm_token: str, user_id: str
    ) -> None:
        """
        Remove FCM token on logout or device uninstall.
        Called by Flutter before logout.
        """
        self.db.table("device_tokens").delete().eq(
            "member_id", user_id
        ).eq("fcm_token", fcm_token).execute()

    # ── Send to Member ────────────────────────────────────────────────────────

    async def send_to_member(
        self,
        member_id: str,
        title: str,
        body: str,
        data: dict = None,
    ) -> NotificationSentResponse:
        """
        Send push notification to all devices of a single member.
        Silently removes invalid tokens.
        """
        tokens = self._get_member_tokens(member_id)
        return await self._dispatch(tokens, title, body, data or {})

    # ── Send to Household ─────────────────────────────────────────────────────

    async def send_to_household(
        self,
        household_id: str,
        title: str,
        body: str,
        data: dict = None,
        exclude_member_id: str = None,
    ) -> NotificationSentResponse:
        """
        Broadcast push to all members of a household.
        Optionally exclude the triggering member (avoid self-notification).
        """
        members = self.db.table("profiles").select("id").eq(
            "household_id", household_id
        ).execute()

        member_ids = [
            m["id"] for m in members.data
            if m["id"] != exclude_member_id
        ]

        if not member_ids:
            return NotificationSentResponse(sent=0, failed=0)

        tokens = self._get_members_tokens(member_ids)
        return await self._dispatch(tokens, title, body, data or {})

    # ── Send to Members List ──────────────────────────────────────────────────

    async def send_to_members(
        self,
        member_ids: list[str],
        title: str,
        body: str,
        data: dict = None,
    ) -> NotificationSentResponse:
        """Send push to a specific list of member IDs."""
        tokens = self._get_members_tokens(member_ids)
        return await self._dispatch(tokens, title, body, data or {})

    # ── Private: FCM Dispatch ─────────────────────────────────────────────────

    async def _dispatch(
        self,
        token_records: list[dict],
        title: str,
        body: str,
        data: dict,
    ) -> NotificationSentResponse:
        """
        Send FCM messages to all given tokens.
        Invalid tokens are removed from device_tokens table.
        Never raises — errors are handled gracefully.
        """
        if not _firebase_enabled:
            return NotificationSentResponse(sent=0, failed=0)

        if not token_records:
            return NotificationSentResponse(sent=0, failed=0)

        sent = 0
        failed = 0
        invalid_tokens = []

        for record in token_records:
            token = record["fcm_token"]
            try:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=title,
                        body=body,
                    ),
                    data={k: str(v) for k, v in data.items()},
                    token=token,
                    android=messaging.AndroidConfig(
                        priority="high",
                        notification=messaging.AndroidNotification(
                            sound="default",
                            click_action="FLUTTER_NOTIFICATION_CLICK",
                        ),
                    ),
                    apns=messaging.APNSConfig(
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(sound="default"),
                        ),
                    ),
                )
                messaging.send(message)
                sent += 1
            except messaging.UnregisteredError:
                # Token no longer valid — remove from DB
                invalid_tokens.append(token)
                failed += 1
            except Exception:
                failed += 1

        # Clean up invalid tokens
        if invalid_tokens:
            self.db.table("device_tokens").delete().in_(
                "fcm_token", invalid_tokens
            ).execute()

        return NotificationSentResponse(sent=sent, failed=failed)

    # ── Private: Token Fetchers ───────────────────────────────────────────────

    def _get_member_tokens(self, member_id: str) -> list[dict]:
        result = self.db.table("device_tokens").select(
            "fcm_token, device_platform"
        ).eq("member_id", member_id).execute()
        return result.data

    def _get_members_tokens(self, member_ids: list[str]) -> list[dict]:
        result = self.db.table("device_tokens").select(
            "fcm_token, device_platform"
        ).in_("member_id", member_ids).execute()
        return result.data
