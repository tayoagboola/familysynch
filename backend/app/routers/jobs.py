"""
Jobs Router — /jobs prefix

All endpoints are protected by CRON_SECRET (not user JWT).
These are called by pg_cron inside Supabase via HTTP POST.

pg_cron setup (run in Supabase SQL editor):

-- Daily nudges at 7AM UTC
select cron.schedule(
  'familysync-daily-nudges',
  '0 7 * * *',
  $$
    select net.http_post(
      url := 'https://familysync-api.herokuapp.com/jobs/daily-nudges',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.cron_secret'),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb
    );
  $$
);

-- Streak check at midnight UTC
select cron.schedule(
  'familysync-streak-check',
  '0 0 * * *',
  $$
    select net.http_post(
      url := 'https://familysync-api.herokuapp.com/jobs/streak-check',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.cron_secret'),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb
    );
  $$
);

-- Badge check every hour
select cron.schedule(
  'familysync-badge-check',
  '0 * * * *',
  $$
    select net.http_post(
      url := 'https://familysync-api.herokuapp.com/jobs/badge-check',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.cron_secret'),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb
    );
  $$
);

-- Store cron secret as Supabase setting
-- alter database postgres set app.cron_secret = '<YOUR_CRON_SECRET>';
"""

from fastapi import APIRouter, Depends

from app.core.dependencies import verify_cron_secret
from app.db.supabase_client import get_supabase
from app.schemas.common import SuccessResponse
from app.services.ai_service import AIService
from app.services.badge_service import BadgeService
from app.services.notification_service import NotificationService
from app.services.streak_service import StreakService

router = APIRouter(prefix="/jobs", tags=["jobs"])


@router.post("/daily-nudges", response_model=SuccessResponse[dict])
async def run_daily_nudges(
    _: None = Depends(verify_cron_secret),
    supabase=Depends(get_supabase),
):
    """
    Generate proactive AI nudges for all households.
    Called daily at 7AM UTC by pg_cron.

    For each household:
    1. Call AIService.generate_nudges() — builds context → calls Claude
    2. Nudge rows inserted into ai_notifications table
    3. Push notification sent to all parent members
    """
    households = supabase.table("households").select("id").execute()

    total_nudges = 0
    total_pushed = 0
    errors = 0

    notification_service = NotificationService(supabase)
    ai_service = AIService(supabase)

    for household in households.data:
        household_id = household["id"]
        try:
            count = await ai_service.generate_nudges(household_id)
            total_nudges += count

            if count > 0:
                result = await notification_service.send_to_household(
                    household_id=household_id,
                    title="FamilyAI has insights for you 🤖",
                    body="Tap to see what needs attention today.",
                    data={"screen": "ai"},
                )
                total_pushed += result.sent
        except Exception:
            errors += 1

    return SuccessResponse(data={
        "households_processed": len(households.data),
        "nudges_generated": total_nudges,
        "pushes_sent": total_pushed,
        "errors": errors,
    })


@router.post("/streak-check", response_model=SuccessResponse[dict])
async def run_streak_check(
    _: None = Depends(verify_cron_secret),
    supabase=Depends(get_supabase),
):
    """
    Check and update household streaks.
    Called daily at midnight UTC by pg_cron.

    For each household:
    1. Check if any task was completed yesterday
    2. Increment streak if yes, reset to 0 if no
    3. Post system feed message on milestone (7, 14, 30, 60, 100 days)
    4. Send push notification on milestone
    """
    streak_service = StreakService(supabase)
    result = await streak_service.check_all_households()
    return SuccessResponse(data=result)


@router.post("/badge-check", response_model=SuccessResponse[dict])
async def run_badge_check(
    _: None = Depends(verify_cron_secret),
    supabase=Depends(get_supabase),
):
    """
    Run badge eligibility check for all child members.
    Called hourly by pg_cron.
    Catches any badges that may have been missed during task completion.

    For each child member:
    1. Fetch their current total_points
    2. Run BadgeService.check_and_award_badges()
    3. Unlock any newly eligible badges
    4. Post system feed message for each unlock
    """
    children = supabase.table("profiles").select(
        "id, household_id"
    ).eq("role", "child").execute()

    total_checked = 0
    total_unlocked = 0
    errors = 0

    badge_service = BadgeService(supabase)
    notification_service = NotificationService(supabase)

    for child in children.data:
        member_id = child["id"]
        household_id = child["household_id"]

        if not household_id:
            continue

        try:
            progress = supabase.table("kid_progress").select(
                "total_points"
            ).eq("member_id", member_id).execute()

            total_points = progress.data[0]["total_points"] if progress.data else 0

            newly_unlocked = await badge_service.check_and_award_badges(
                member_id=member_id,
                household_id=household_id,
                total_points=total_points,
            )

            total_checked += 1
            total_unlocked += len(newly_unlocked)

            if newly_unlocked:
                child_profile = supabase.table("profiles").select(
                    "full_name"
                ).eq("id", member_id).single().execute()
                child_name = child_profile.data.get("full_name", "Your child") if child_profile.data else "Your child"

                for badge in newly_unlocked:
                    await notification_service.send_to_household(
                        household_id=household_id,
                        title=f"{badge.emoji} Badge unlocked!",
                        body=f"{child_name} earned '{badge.name}'!",
                        data={"screen": "kid", "member_id": member_id},
                        exclude_member_id=None,
                    )

        except Exception:
            errors += 1

    return SuccessResponse(data={
        "children_checked": total_checked,
        "badges_unlocked": total_unlocked,
        "errors": errors,
    })
