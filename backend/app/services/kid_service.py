"""
Kid Service

Responsibilities:
- award_xp(): called by TaskService when child completes a task
  → Updates kid_progress table
  → Checks for level up
  → Triggers badge eligibility check
  → Posts system message to feed if level up or badge unlocked
  → Sends push notification to child (optional)

- get_progress(): fetch kid progress for Kid Mode home screen XP bar

- get_badges(): fetch all badges (earned + locked) for badge shelf

Level system:
  Level 1 — Starter     (0–99 XP)
  Level 2 — Helper      (100–249 XP)
  Level 3 — Champion    (250–499 XP)
  Level 4 — Explorer    (500–899 XP)
  Level 5 — Superstar   (900–1399 XP)
  Level 6+ — Legend     (1400+ XP, every 600 XP thereafter)

Stars display:
  Level 1–2: ⭐
  Level 3–4: ⭐⭐
  Level 5+:  ⭐⭐⭐

Rules:
- kid_progress row is created lazily on first XP award if it doesn't exist
- Level up only happens forward — never backward
- Badge check runs after every XP award
- System feed post created on level up and badge unlock
"""

import uuid

from fastapi import Depends
from supabase import Client

from app.db.supabase_client import get_supabase
from app.schemas.kid import (
    BadgeDefinitionResponse,
    BadgeShelfResponse,
    EarnedBadgeResponse,
    KidProgressResponse,
    XPAwardResponse,
)


# ── Level System ──────────────────────────────────────────────────────────────

LEVELS = [
    {"level": 1, "name": "Starter",   "xp_needed": 100},
    {"level": 2, "name": "Helper",    "xp_needed": 150},
    {"level": 3, "name": "Champion",  "xp_needed": 250},
    {"level": 4, "name": "Explorer",  "xp_needed": 400},
    {"level": 5, "name": "Superstar", "xp_needed": 500},
]
DEFAULT_XP_PER_LEVEL = 600  # Level 6+


def _get_level_info(total_points: int) -> dict:
    """Calculate level, level name, XP in level, XP needed for next level."""
    accumulated = 0
    for entry in LEVELS:
        if total_points < accumulated + entry["xp_needed"]:
            xp_in_level = total_points - accumulated
            return {
                "level": entry["level"],
                "name": entry["name"],
                "xp_in_level": xp_in_level,
                "xp_needed": entry["xp_needed"],
            }
        accumulated += entry["xp_needed"]

    # Level 6+
    excess = total_points - accumulated
    level = 6 + (excess // DEFAULT_XP_PER_LEVEL)
    xp_in_level = excess % DEFAULT_XP_PER_LEVEL
    return {
        "level": level,
        "name": "Legend",
        "xp_in_level": xp_in_level,
        "xp_needed": DEFAULT_XP_PER_LEVEL,
    }


def _stars_display(level: int) -> str:
    if level <= 2:
        return "⭐"
    elif level <= 4:
        return "⭐⭐"
    return "⭐⭐⭐"


class KidService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Award XP ──────────────────────────────────────────────────────────────

    async def award_xp(
        self,
        member_id: str,
        points: int,
        household_id: str,
    ) -> XPAwardResponse:
        """
        Called by TaskService after child completes a task.
        1. Upsert kid_progress row (create lazily if first time)
        2. Add points to total_points
        3. Calculate new level from total_points
        4. Check for level up → post system feed message
        5. Run badge check → post system feed message for each unlock
        6. Return XPAwardResponse
        """
        existing = self.db.table("kid_progress").select("*").eq(
            "member_id", member_id
        ).execute()

        if existing.data:
            progress = existing.data[0]
            old_level = progress["current_level"]
            new_total = progress["total_points"] + points

            level_info = _get_level_info(new_total)
            new_level = level_info["level"]

            self.db.table("kid_progress").update({
                "total_points": new_total,
                "current_level": new_level,
                "xp_in_current_level": level_info["xp_in_level"],
                "xp_needed_for_next_level": level_info["xp_needed"],
            }).eq("member_id", member_id).execute()

        else:
            # First XP award — create progress row
            old_level = 0
            new_total = points
            level_info = _get_level_info(new_total)
            new_level = level_info["level"]

            self.db.table("kid_progress").insert({
                "id": str(uuid.uuid4()),
                "member_id": member_id,
                "total_points": new_total,
                "current_level": new_level,
                "xp_in_current_level": level_info["xp_in_level"],
                "xp_needed_for_next_level": level_info["xp_needed"],
                "streak_days": 0,
            }).execute()

        leveled_up = new_level > old_level

        # Post system feed message on level up
        if leveled_up:
            member = self.db.table("profiles").select(
                "full_name"
            ).eq("id", member_id).single().execute()
            name = member.data.get("full_name", "Your child") if member.data else "Your child"

            from app.services.feed_service import FeedService
            feed_service = FeedService(self.db)
            await feed_service.create_system_post(
                content=f"🎉 {name} just reached Level {new_level} — {level_info['name']}! Keep it up! 🚀",
                household_id=household_id,
                post_type="achievement",
            )

        # Run badge check
        from app.services.badge_service import BadgeService
        badge_service = BadgeService(self.db)
        unlocked_badges = await badge_service.check_and_award_badges(
            member_id=member_id,
            household_id=household_id,
            total_points=new_total,
        )

        return XPAwardResponse(
            member_id=member_id,
            points_awarded=points,
            total_points=new_total,
            leveled_up=leveled_up,
            new_level=new_level if leveled_up else None,
            badges_unlocked=unlocked_badges,
        )

    # ── Get Progress ──────────────────────────────────────────────────────────

    async def get_progress(self, member_id: str) -> KidProgressResponse:
        """
        Fetch kid XP and level for Kid Mode home screen.
        Returns defaults if no progress row exists yet.
        """
        result = self.db.table("kid_progress").select("*").eq(
            "member_id", member_id
        ).execute()

        if not result.data:
            return KidProgressResponse(
                member_id=member_id,
                total_points=0,
                current_level=1,
                level_name="Starter",
                xp_in_current_level=0,
                xp_needed_for_next_level=100,
                level_progress_pct=0.0,
                streak_days=0,
                stars_display="⭐",
            )

        p = result.data[0]
        level_info = _get_level_info(p["total_points"])
        progress_pct = round(
            level_info["xp_in_level"] / level_info["xp_needed"], 2
        ) if level_info["xp_needed"] > 0 else 1.0

        return KidProgressResponse(
            member_id=member_id,
            total_points=p["total_points"],
            current_level=p["current_level"],
            level_name=level_info["name"],
            xp_in_current_level=level_info["xp_in_level"],
            xp_needed_for_next_level=level_info["xp_needed"],
            level_progress_pct=progress_pct,
            streak_days=p.get("streak_days", 0),
            stars_display=_stars_display(p["current_level"]),
        )

    # ── Get Badges ────────────────────────────────────────────────────────────

    async def get_badges(self, member_id: str) -> BadgeShelfResponse:
        """
        Fetch all badge definitions and mark which ones are earned.
        Returns earned (with earned_at) and locked lists.
        """
        all_badges = self.db.table("badge_definitions").select(
            "*"
        ).order("requirement_value").execute()

        earned_records = self.db.table("kid_badges").select(
            "badge_id, earned_at"
        ).eq("member_id", member_id).execute()

        earned_ids = {
            r["badge_id"]: r["earned_at"] for r in earned_records.data
        }

        earned = []
        locked = []

        for b in all_badges.data:
            badge_def = BadgeDefinitionResponse(
                id=b["id"],
                name=b["name"],
                description=b.get("description", ""),
                emoji=b["emoji"],
                gradient_color_1=b.get("gradient_color_1", "#FFD166"),
                gradient_color_2=b.get("gradient_color_2", "#FFAB00"),
                requirement_type=b.get("requirement_type", "tasks_completed"),
                requirement_value=b.get("requirement_value", 1),
            )
            if b["id"] in earned_ids:
                earned.append(EarnedBadgeResponse(
                    badge=badge_def,
                    earned_at=earned_ids[b["id"]],
                ))
            else:
                locked.append(badge_def)

        return BadgeShelfResponse(
            earned=earned,
            locked=locked,
            total_earned=len(earned),
            total_available=len(all_badges.data),
        )
