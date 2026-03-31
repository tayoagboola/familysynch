from pydantic import BaseModel
from typing import Optional, List


# ── Responses ─────────────────────────────────────────────────────────────────

class KidProgressResponse(BaseModel):
    member_id: str
    total_points: int
    current_level: int
    level_name: str
    xp_in_current_level: int
    xp_needed_for_next_level: int
    level_progress_pct: float           # 0.0 → 1.0
    streak_days: int
    stars_display: str                  # "⭐⭐⭐" based on level


class BadgeDefinitionResponse(BaseModel):
    id: str
    name: str
    description: str
    emoji: str
    gradient_color_1: str
    gradient_color_2: str
    requirement_type: str               # streak | tasks_completed | points_earned
    requirement_value: int


class EarnedBadgeResponse(BaseModel):
    badge: BadgeDefinitionResponse
    earned_at: str
    is_earned: bool = True


class BadgeShelfResponse(BaseModel):
    earned: List[EarnedBadgeResponse]
    locked: List[BadgeDefinitionResponse]
    total_earned: int
    total_available: int


class XPAwardResponse(BaseModel):
    member_id: str
    points_awarded: int
    total_points: int
    leveled_up: bool
    new_level: Optional[int]
    badges_unlocked: List[BadgeDefinitionResponse]
