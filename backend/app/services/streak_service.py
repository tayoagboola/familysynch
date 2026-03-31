"""
Streak Service

Manages the household completion streak — how many consecutive days
at least one task was completed by any household member.

Streak rules:
- A streak day counts if at least 1 task was completed that calendar day
- Streak increments at midnight if the day had completions
- Streak resets to 0 if a day passes with zero completions
- Streak is stored on the households table (streak_days column)
- When streak reaches milestones (7, 14, 30 days), post system feed message

Streak milestones: 7, 14, 30, 60, 100 days
Called by: /jobs/streak-check (pg_cron at midnight UTC)
"""

from datetime import datetime, timezone, timedelta

from fastapi import Depends
from supabase import Client

from app.db.supabase_client import get_supabase


STREAK_MILESTONES = [7, 14, 30, 60, 100]


class StreakService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    async def check_all_households(self) -> dict:
        """
        Run streak check for every household.
        Called by pg_cron at midnight UTC.
        Returns summary of updates made.
        """
        households = self.db.table("households").select("id, streak_days").execute()

        updated = 0
        reset = 0
        milestone_hits = 0

        for household in households.data:
            result = await self.check_household(household["id"], household["streak_days"])
            if result["action"] == "incremented":
                updated += 1
                if result.get("milestone_hit"):
                    milestone_hits += 1
            elif result["action"] == "reset":
                reset += 1

        return {
            "households_checked": len(households.data),
            "streaks_incremented": updated,
            "streaks_reset": reset,
            "milestone_hits": milestone_hits,
        }

    async def check_household(
        self, household_id: str, current_streak: int
    ) -> dict:
        """
        Check if household completed any tasks yesterday.
        Increment or reset streak accordingly.
        Post system feed message on milestone.
        """
        yesterday = (
            datetime.now(timezone.utc) - timedelta(days=1)
        ).date().isoformat()

        completions = self.db.table("tasks").select(
            "id", count="exact"
        ).eq("household_id", household_id).eq(
            "is_completed", True
        ).gte("completed_at", f"{yesterday}T00:00:00+00:00").lt(
            "completed_at", f"{yesterday}T23:59:59+00:00"
        ).execute()

        had_completions = (completions.count or 0) > 0

        if had_completions:
            new_streak = current_streak + 1
            self.db.table("households").update({
                "streak_days": new_streak
            }).eq("id", household_id).execute()

            milestone_hit = new_streak in STREAK_MILESTONES
            if milestone_hit:
                await self._post_streak_milestone(household_id, new_streak)

            return {"action": "incremented", "new_streak": new_streak, "milestone_hit": milestone_hit}
        else:
            if current_streak > 0:
                self.db.table("households").update({
                    "streak_days": 0
                }).eq("id", household_id).execute()
            return {"action": "reset", "new_streak": 0}

    async def _post_streak_milestone(
        self, household_id: str, streak_days: int
    ) -> None:
        """Post a celebration system feed message on streak milestone."""
        emojis = {7: "🔥", 14: "💪", 30: "🚀", 60: "⭐", 100: "👑"}
        emoji = emojis.get(streak_days, "🎉")

        from app.services.feed_service import FeedService
        from app.services.notification_service import NotificationService

        feed_service = FeedService(self.db)
        await feed_service.create_system_post(
            content=f"{emoji} Your family is on a {streak_days}-day streak! Amazing teamwork! 🏆",
            household_id=household_id,
            post_type="celebration",
        )

        notification_service = NotificationService(self.db)
        await notification_service.send_to_household(
            household_id=household_id,
            title=f"{emoji} {streak_days}-Day Streak!",
            body="Your family is crushing it! Keep going! 💪",
            data={"screen": "home"},
        )
