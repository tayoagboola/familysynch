"""
Feed Service

Rules:
- Posts belong to a household — only members can see/modify them
- author_id is None for system posts (achievements, streaks, AI nudges)
- linked_event_id and linked_task_id must belong to the same household
- Reactions are unique per (post_id, member_id, emoji)
- Toggle reaction: exists → remove. Does not exist → add.
- Pagination: cursor = created_at of last post (ISO string), fetch older posts
- Delete permission: only author OR any parent in household
- Reactions cascade delete when post is deleted via SQL FK
- create_system_post() is called internally by KidService and JobsService
- Every mutation broadcasts via ws_manager
"""

import uuid
from typing import Optional

from fastapi import Depends
from supabase import Client

from app.core.exceptions import FamilySyncException
from app.core.websocket_manager import ws_manager
from app.db.supabase_client import get_supabase
from app.schemas.feed import (
    AuthorResponse,
    CreatePostRequest,
    FeedResponse,
    LinkedEventResponse,
    LinkedTaskResponse,
    PostResponse,
    ReactRequest,
    ReactionSummary,
)

_FEED_SELECT = (
    "*, "
    "profiles!feed_posts_author_id_fkey(id, full_name, initials, avatar_url),"
    "events!feed_posts_linked_event_id_fkey(id, title, start_time, color),"
    "tasks!feed_posts_linked_task_id_fkey(id, title, assigned_member_id),"
    "feed_reactions(id, member_id, emoji)"
)


class FeedService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Get Feed ──────────────────────────────────────────────────────────────

    async def get_feed(
        self,
        household_id: str,
        user_id: str,
        post_type: Optional[str] = None,
        cursor: Optional[str] = None,
        limit: int = 20,
    ) -> FeedResponse:
        """
        Paginated feed — newest first.
        cursor = created_at of last received post → returns older posts.
        Uses limit+1 trick to determine has_more without extra query.
        """
        query = self.db.table("feed_posts").select(_FEED_SELECT).eq(
            "household_id", household_id
        )

        if post_type:
            query = query.eq("type", post_type)
        if cursor:
            query = query.lt("created_at", cursor)

        result = query.order("created_at", desc=True).limit(limit + 1).execute()

        posts_data = result.data
        has_more = len(posts_data) > limit
        if has_more:
            posts_data = posts_data[:limit]

        next_cursor = posts_data[-1]["created_at"] if has_more and posts_data else None
        posts = [self._format_post(p, user_id) for p in posts_data]

        return FeedResponse(
            posts=posts,
            total=len(posts),
            has_more=has_more,
            next_cursor=next_cursor,
        )

    # ── Create Post ───────────────────────────────────────────────────────────

    async def create_post(
        self,
        body: CreatePostRequest,
        user_id: str,
        household_id: str,
    ) -> PostResponse:
        """
        1. Validate linked IDs belong to household
        2. Insert post row
        3. Broadcast feed:post_added
        4. Return post with author + linked data + reactions
        """
        if body.linked_event_id:
            event = self.db.table("events").select("id").eq(
                "id", body.linked_event_id
            ).eq("household_id", household_id).execute()
            if not event.data:
                raise FamilySyncException(404, "Linked event not found")

        if body.linked_task_id:
            task = self.db.table("tasks").select("id").eq(
                "id", body.linked_task_id
            ).eq("household_id", household_id).execute()
            if not task.data:
                raise FamilySyncException(404, "Linked task not found")

        post_id = str(uuid.uuid4())
        self.db.table("feed_posts").insert({
            "id": post_id,
            "household_id": household_id,
            "author_id": user_id,
            "content": body.content,
            "type": body.type.value,
            "linked_event_id": body.linked_event_id,
            "linked_task_id": body.linked_task_id,
        }).execute()

        post = await self._get_post_with_details(post_id, user_id)
        await ws_manager.broadcast(
            household_id, "feed:post_added", post.model_dump()
        )
        return post

    # ── Create System Post ────────────────────────────────────────────────────

    async def create_system_post(
        self,
        content: str,
        household_id: str,
        post_type: str = "system",
        linked_task_id: Optional[str] = None,
    ) -> PostResponse:
        """
        Internal method — called by KidService (badge/level up)
        and JobsService (streak milestone, nudge).
        author_id is None → Flutter renders with AI/system avatar.
        """
        post_id = str(uuid.uuid4())
        self.db.table("feed_posts").insert({
            "id": post_id,
            "household_id": household_id,
            "author_id": None,
            "content": content,
            "type": post_type,
            "linked_task_id": linked_task_id,
        }).execute()

        post = await self._get_post_with_details(post_id, user_id=None)
        await ws_manager.broadcast(
            household_id, "feed:post_added", post.model_dump()
        )
        return post

    # ── Delete Post ───────────────────────────────────────────────────────────

    async def delete_post(
        self,
        post_id: str,
        household_id: str,
        user_id: str,
    ) -> None:
        """
        Only author or parent can delete.
        Reactions cascade delete via FK.
        Broadcasts feed:post_deleted.
        """
        post = self.db.table("feed_posts").select(
            "id, author_id"
        ).eq("id", post_id).eq("household_id", household_id).single().execute()

        if not post.data:
            raise FamilySyncException(404, "Post not found")

        if post.data["author_id"] != user_id:
            profile = self.db.table("profiles").select("role").eq(
                "id", user_id
            ).single().execute()
            if not profile.data or profile.data.get("role") != "parent":
                raise FamilySyncException(403, "Not authorised to delete this post")

        self.db.table("feed_posts").delete().eq("id", post_id).execute()
        await ws_manager.broadcast(
            household_id, "feed:post_deleted", {"post_id": post_id}
        )

    # ── Toggle Reaction ───────────────────────────────────────────────────────

    async def toggle_reaction(
        self,
        post_id: str,
        household_id: str,
        user_id: str,
        body: ReactRequest,
    ) -> PostResponse:
        """
        Toggle emoji reaction.
        Already reacted with this emoji → remove.
        Not yet reacted → add.
        Broadcasts feed:reaction_added or feed:reaction_removed.
        """
        post = self.db.table("feed_posts").select("id").eq(
            "id", post_id
        ).eq("household_id", household_id).execute()
        if not post.data:
            raise FamilySyncException(404, "Post not found")

        existing = self.db.table("feed_reactions").select("id").eq(
            "post_id", post_id
        ).eq("member_id", user_id).eq("emoji", body.emoji).execute()

        if existing.data:
            self.db.table("feed_reactions").delete().eq(
                "id", existing.data[0]["id"]
            ).execute()
            event_type = "feed:reaction_removed"
        else:
            self.db.table("feed_reactions").insert({
                "id": str(uuid.uuid4()),
                "post_id": post_id,
                "member_id": user_id,
                "emoji": body.emoji,
            }).execute()
            event_type = "feed:reaction_added"

        updated_post = await self._get_post_with_details(post_id, user_id)
        await ws_manager.broadcast(
            household_id, event_type, {
                "post_id": post_id,
                "emoji": body.emoji,
                "member_id": user_id,
                "reactions": [r.model_dump() for r in updated_post.reactions],
            }
        )
        return updated_post

    # ── Private Helpers ───────────────────────────────────────────────────────

    async def _get_post_with_details(
        self, post_id: str, user_id: Optional[str]
    ) -> PostResponse:
        result = self.db.table("feed_posts").select(_FEED_SELECT).eq(
            "id", post_id
        ).single().execute()
        return self._format_post(result.data, user_id)

    def _format_post(self, p: dict, user_id: Optional[str]) -> PostResponse:
        author_data = p.get("profiles") or {}
        author = AuthorResponse(
            id=author_data.get("id", ""),
            full_name=author_data.get("full_name", ""),
            initials=author_data.get("initials", ""),
            avatar_url=author_data.get("avatar_url"),
        ) if author_data else None

        event_data = p.get("events") or {}
        linked_event = LinkedEventResponse(
            id=event_data.get("id", ""),
            title=event_data.get("title", ""),
            start_time=event_data.get("start_time", ""),
            color=event_data.get("color", "orange"),
        ) if event_data else None

        task_data = p.get("tasks") or {}
        linked_task = LinkedTaskResponse(
            id=task_data.get("id", ""),
            title=task_data.get("title", ""),
            assigned_member_id=task_data.get("assigned_member_id", ""),
        ) if task_data else None

        # Group reactions by emoji
        raw_reactions = p.get("feed_reactions", [])
        emoji_map: dict[str, list[str]] = {}
        for r in raw_reactions:
            emoji_map.setdefault(r["emoji"], []).append(r["member_id"])

        reactions = [
            ReactionSummary(
                emoji=emoji,
                count=len(member_ids),
                reacted_by_me=user_id in member_ids if user_id else False,
            )
            for emoji, member_ids in emoji_map.items()
        ]

        return PostResponse(
            id=p["id"],
            household_id=p["household_id"],
            author_id=p.get("author_id"),
            author=author,
            content=p["content"],
            type=p.get("type", "message"),
            linked_event=linked_event,
            linked_task=linked_task,
            reactions=reactions,
            created_at=p.get("created_at", ""),
        )
