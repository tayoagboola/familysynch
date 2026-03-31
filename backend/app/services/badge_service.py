"""
Badge Service

Checks badge eligibility after XP is awarded.
Awards any newly earned badges and posts system feed messages.
Called internally by KidService — no router endpoints.

Badge requirement types:
- streak:           household streak_days >= requirement_value
- tasks_completed:  total tasks completed by member >= requirement_value
- points_earned:    total_points >= requirement_value
"""

import uuid
from datetime import datetime, timezone

from fastapi import Depends
from supabase import Client

from app.db.supabase_client import get_supabase
from app.schemas.kid import BadgeDefinitionResponse


class BadgeService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    async def check_and_award_badges(
        self,
        member_id: str,
        household_id: str,
        total_points: int,
    ) -> list[BadgeDefinitionResponse]:
        """
        1. Fetch all badge definitions
        2. Fetch already earned badges for this member
        3. For each unearned badge, check eligibility
        4. Award newly eligible badges
        5. Post system feed message for each unlock
        6. Return list of newly unlocked badges
        """
        all_badges = self.db.table("badge_definitions").select("*").execute()
        earned = self.db.table("kid_badges").select("badge_id").eq(
            "member_id", member_id
        ).execute()
        earned_ids = {r["badge_id"] for r in earned.data}

        # Gather stats needed for evaluation
        tasks_completed = self.db.table("tasks").select(
            "id", count="exact"
        ).eq("assigned_member_id", member_id).eq("is_completed", True).execute()
        tasks_count = tasks_completed.count or 0

        household = self.db.table("households").select(
            "streak_days"
        ).eq("id", household_id).single().execute()
        streak_days = household.data.get("streak_days", 0) if household.data else 0

        newly_unlocked = []

        for badge in all_badges.data:
            if badge["id"] in earned_ids:
                continue

            eligible = False
            req_type  = badge.get("requirement_type", "")
            req_value = badge.get("requirement_value", 0)

            if req_type == "points_earned":
                eligible = total_points >= req_value
            elif req_type == "tasks_completed":
                eligible = tasks_count >= req_value
            elif req_type == "streak":
                eligible = streak_days >= req_value

            if eligible:
                self.db.table("kid_badges").insert({
                    "id": str(uuid.uuid4()),
                    "member_id": member_id,
                    "badge_id": badge["id"],
                    "earned_at": datetime.now(timezone.utc).isoformat(),
                }).execute()

                badge_def = BadgeDefinitionResponse(
                    id=badge["id"],
                    name=badge["name"],
                    description=badge.get("description", ""),
                    emoji=badge["emoji"],
                    gradient_color_1=badge.get("gradient_color_1", "#FFD166"),
                    gradient_color_2=badge.get("gradient_color_2", "#FFAB00"),
                    requirement_type=req_type,
                    requirement_value=req_value,
                )
                newly_unlocked.append(badge_def)

                # Post system feed message
                member = self.db.table("profiles").select(
                    "full_name"
                ).eq("id", member_id).single().execute()
                name = member.data.get("full_name", "Your child") if member.data else "Your child"

                from app.services.feed_service import FeedService
                feed_service = FeedService(self.db)
                await feed_service.create_system_post(
                    content=f"{badge['emoji']} {name} just unlocked the '{badge['name']}' badge! 🏆",
                    household_id=household_id,
                    post_type="achievement",
                )

        return newly_unlocked
