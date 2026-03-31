"""
AI Service

Responsibilities:
- chat(): build family context from live DB → call Claude API → return reply
- generate_nudges(): called by JobsService daily — analyse family data,
  generate proactive nudge text, insert into ai_notifications table
- get_nudges(): fetch unread nudges for a member (Flutter FAB badge count)
- mark_nudges_read(): dismiss nudges after user reads them

Context building strategy:
- Only fetch data for active_context scopes (Calendar, Tasks, Grocery, Members)
- Limit context size to avoid token overflow:
    Calendar:  next 7 days events (max 10)
    Tasks:     pending tasks (max 15)
    Grocery:   unchecked items (max 20)
    Members:   all member names + roles
- Trim conversation history to last 10 messages max
- System prompt explains the family context and instructs Claude to be
  conversational, concise, warm, and family-focused

Claude model: claude-sonnet-4-6
Max tokens: 500 per response (chat)
Max tokens: 400 per nudge (nudge generation)

Rate limiting: 30 requests/hour per user — applied in router
"""

import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional

from anthropic import Anthropic
from fastapi import Depends
from supabase import Client

from app.core.config import settings
from app.core.exceptions import FamilySyncException
from app.db.supabase_client import get_supabase
from app.schemas.ai import (
    ChatRequest,
    ChatResponse,
    ContextScope,
    MarkNudgeReadRequest,
    NudgeListResponse,
    NudgeResponse,
)


class AIService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase
        self.claude = Anthropic(api_key=settings.anthropic_api_key)

    # ── Chat ──────────────────────────────────────────────────────────────────

    async def chat(
        self,
        body: ChatRequest,
        user_id: str,
        household_id: str,
    ) -> ChatResponse:
        """
        1. Fetch family context for active scopes
        2. Build system prompt with injected context
        3. Trim history to last 10 messages
        4. Call Claude API
        5. Return reply + context_used
        """
        context = await self._build_context(
            household_id, user_id, body.active_context
        )
        system_prompt = self._build_system_prompt(context, user_id, household_id)

        # Trim history to last 10 exchanges
        history = body.history[-10:] if len(body.history) > 10 else body.history

        messages = [
            {"role": msg.role, "content": msg.content}
            for msg in history
        ]
        messages.append({"role": "user", "content": body.message})

        try:
            response = self.claude.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=500,
                system=system_prompt,
                messages=messages,
            )
            reply = response.content[0].text
        except Exception as e:
            raise FamilySyncException(503, f"AI service unavailable: {str(e)}")

        return ChatResponse(
            reply=reply,
            context_used=body.active_context,
        )

    # ── Generate Nudges ───────────────────────────────────────────────────────

    async def generate_nudges(self, household_id: str) -> int:
        """
        Called by JobsService daily at 7AM.
        1. Fetch family context (all scopes)
        2. Ask Claude to identify what needs attention today
        3. Insert nudge rows into ai_notifications table
        4. Return count of nudges generated
        """
        context = await self._build_context(
            household_id,
            user_id=None,
            scopes=list(ContextScope),
        )

        if not context:
            return 0

        # Get all parent members to receive nudges
        members = self.db.table("profiles").select("id, full_name, role").eq(
            "household_id", household_id
        ).execute()
        parent_ids = [m["id"] for m in members.data if m.get("role") == "parent"]

        if not parent_ids:
            return 0

        system_prompt = """You are FamilyAI, a family assistant.
Analyse the family data below and identify 1-3 things that need attention today.
For each item, respond with EXACTLY this JSON format (array):
[
  {
    "title": "Short title (max 8 words)",
    "body": "One sentence explanation with names and specifics (max 25 words)",
    "type": "reminder|suggestion|warning|celebration"
  }
]
Return ONLY the JSON array. No other text."""

        context_text = self._format_context_for_nudge(context)

        try:
            response = self.claude.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=400,
                system=system_prompt,
                messages=[{"role": "user", "content": context_text}],
            )
            import json
            raw = response.content[0].text.strip()
            nudges_data = json.loads(raw)
        except Exception:
            return 0

        if not isinstance(nudges_data, list):
            return 0

        expires_at = (
            datetime.now(timezone.utc) + timedelta(hours=18)
        ).isoformat()

        count = 0
        for nudge in nudges_data[:3]:
            if not all(k in nudge for k in ("title", "body", "type")):
                continue
            for member_id in parent_ids:
                self.db.table("ai_notifications").insert({
                    "id": str(uuid.uuid4()),
                    "household_id": household_id,
                    "target_member_id": member_id,
                    "title": nudge["title"],
                    "body": nudge["body"],
                    "type": nudge.get("type", "reminder"),
                    "is_read": False,
                    "expires_at": expires_at,
                }).execute()
                count += 1

        return count

    # ── Get Nudges ────────────────────────────────────────────────────────────

    async def get_nudges(
        self, user_id: str, household_id: str
    ) -> NudgeListResponse:
        """
        Fetch nudges for the current user.
        Used by Flutter for FAB badge count and home screen nudge card.
        Expired nudges are excluded.
        """
        now = datetime.now(timezone.utc).isoformat()

        result = self.db.table("ai_notifications").select("*").eq(
            "target_member_id", user_id
        ).eq("household_id", household_id).order(
            "created_at", desc=True
        ).execute()

        nudges = []
        for n in result.data:
            # Skip expired nudges
            if n.get("expires_at") and n["expires_at"] < now:
                continue
            nudges.append(NudgeResponse(
                id=n["id"],
                title=n["title"],
                body=n["body"],
                type=n.get("type", "reminder"),
                is_read=n.get("is_read", False),
                created_at=n.get("created_at", ""),
                expires_at=n.get("expires_at"),
            ))

        unread = sum(1 for n in nudges if not n.is_read)
        return NudgeListResponse(nudges=nudges, unread_count=unread)

    # ── Mark Nudges Read ──────────────────────────────────────────────────────

    async def mark_nudges_read(
        self, body: MarkNudgeReadRequest, user_id: str
    ) -> None:
        """Mark one or more nudges as read."""
        if not body.nudge_ids:
            return
        self.db.table("ai_notifications").update({
            "is_read": True
        }).in_("id", body.nudge_ids).eq("target_member_id", user_id).execute()

    # ── Context Builder ───────────────────────────────────────────────────────

    async def _build_context(
        self,
        household_id: str,
        user_id: Optional[str],
        scopes: list,
    ) -> dict:
        """Fetch live family data for requested context scopes."""
        context = {}
        today = datetime.now(timezone.utc)
        week_later = (today + timedelta(days=7)).isoformat()
        scope_values = [s.value if hasattr(s, "value") else s for s in scopes]

        if "members" in scope_values:
            members = self.db.table("profiles").select(
                "id, full_name, initials, role"
            ).eq("household_id", household_id).execute()
            context["members"] = members.data

        if "calendar" in scope_values:
            events = self.db.table("events").select(
                "title, start_time, end_time, location, "
                "event_members(member_id)"
            ).eq("household_id", household_id).gte(
                "start_time", today.isoformat()
            ).lt("start_time", week_later).order(
                "start_time"
            ).limit(10).execute()
            context["upcoming_events"] = events.data

        if "tasks" in scope_values:
            tasks = self.db.table("tasks").select(
                "title, due_date, priority, is_completed, assigned_member_id"
            ).eq("household_id", household_id).eq(
                "is_completed", False
            ).order("priority", desc=True).limit(15).execute()
            context["pending_tasks"] = tasks.data

        if "grocery" in scope_values:
            grocery = self.db.table("grocery_items").select(
                "name, category, quantity, is_checked"
            ).eq("household_id", household_id).order(
                "is_checked"
            ).limit(20).execute()
            context["grocery_items"] = grocery.data

        return context

    def _build_system_prompt(
        self, context: dict, user_id: str, household_id: str
    ) -> str:
        """Build Claude system prompt with injected family context."""
        import json

        members = context.get("members", [])
        member_names = ", ".join(m["full_name"] for m in members) if members else "your family"

        context_summary = json.dumps(
            {k: v for k, v in context.items()},
            indent=2,
            default=str,
        )

        return f"""You are FamilyAI, a warm and helpful assistant for the {member_names} household.

You have access to their live family data:
{context_summary}

Guidelines:
- Be conversational, warm, and concise (under 120 words unless listing items)
- Use family member names when referencing specific people
- Use emojis naturally but sparingly
- When showing lists (events, tasks, grocery), format them clearly
- Proactively mention anything urgent or time-sensitive you notice
- If asked to do something (add item, send reminder), confirm what you would do
- Never reveal raw database IDs or technical details

Today is {datetime.now(timezone.utc).strftime('%A, %B %d, %Y')}."""

    def _format_context_for_nudge(self, context: dict) -> str:
        """Format context as readable text for nudge generation prompt."""
        lines = ["Here is today's family data:\n"]

        if context.get("members"):
            names = [m["full_name"] for m in context["members"]]
            lines.append(f"Family members: {', '.join(names)}")

        if context.get("upcoming_events"):
            lines.append("\nUpcoming events:")
            for e in context["upcoming_events"]:
                lines.append(f"  - {e['title']} at {e['start_time']}")

        if context.get("pending_tasks"):
            lines.append("\nPending tasks:")
            for t in context["pending_tasks"]:
                lines.append(
                    f"  - {t['title']} (priority: {t['priority']}, due: {t.get('due_date', 'no date')})"
                )

        if context.get("grocery_items"):
            unchecked = [i for i in context["grocery_items"] if not i["is_checked"]]
            lines.append(f"\nGrocery items remaining: {len(unchecked)}")

        lines.append("\nWhat needs attention today?")
        return "\n".join(lines)
