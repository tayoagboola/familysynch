"""
Grocery Service

Rules:
- Items belong to a household — only members can see/modify them
- Category is inferred from item name if not provided by Flutter
- Checked items sort to the bottom of the list
- Toggle is idempotent — safe to call multiple times
- Clear checked: deletes ALL checked items in one operation
- Offline batch sync uses local_id as idempotency key — no duplicates on retry
- Every mutation broadcasts via ws_manager to all connected Flutter clients
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from fastapi import Depends
from supabase import Client

from app.core.exceptions import FamilySyncException
from app.core.websocket_manager import ws_manager
from app.db.supabase_client import get_supabase
from app.schemas.grocery import (
    AddedByResponse,
    AddGroceryItemRequest,
    BatchSyncRequest,
    BatchSyncResponse,
    GroceryCategory,
    GroceryItemResponse,
    GroceryListResponse,
    UpdateGroceryItemRequest,
)


# ── Category Inference ────────────────────────────────────────────────────────

CATEGORY_KEYWORDS: dict[str, list[str]] = {
    "dairy":   ["milk", "cheese", "yogurt", "butter", "cream", "eggs",
                "kefir", "sour cream", "whipping"],
    "produce": ["apple", "banana", "orange", "grape", "berry", "berries",
                "lettuce", "spinach", "kale", "tomato", "cucumber", "carrot",
                "onion", "garlic", "pepper", "broccoli", "potato", "avocado",
                "lemon", "lime", "mango", "peach", "pear", "plum", "melon",
                "celery", "zucchini", "mushroom", "herbs", "basil", "cilantro"],
    "meat":    ["chicken", "beef", "pork", "fish", "salmon", "tuna", "shrimp",
                "turkey", "lamb", "steak", "ground", "sausage", "bacon",
                "ham", "salami", "pepperoni", "prawn"],
    "care":    ["shampoo", "conditioner", "soap", "toothpaste", "toothbrush",
                "deodorant", "razor", "lotion", "moisturizer", "sunscreen",
                "toilet paper", "tissue", "paper towel", "detergent",
                "dish soap", "laundry", "bleach", "sponge", "wipes"],
    "bakery":  ["bread", "bun", "bagel", "muffin", "croissant", "roll",
                "tortilla", "pita", "naan", "cake", "cookie", "pastry"],
    "frozen":  ["frozen", "ice cream", "ice", "popsicle", "pizza"],
    "drinks":  ["orange juice", "apple juice", "grape juice", "fruit juice",
                "juice", "water", "soda", "cola", "coffee", "tea", "beer",
                "wine", "kombucha", "energy drink", "smoothie"],
}


def infer_category(name: str) -> GroceryCategory:
    """
    Infer grocery category from item name.
    Uses word-boundary prefix matching (handles plurals like 'apples').
    Longest keyword wins — so 'orange juice' → drinks not produce.
    """
    import re
    lower = name.lower()
    best_cat: Optional[str] = None
    best_len = 0
    for category, keywords in CATEGORY_KEYWORDS.items():
        for kw in keywords:
            # \b at start only — allows plural suffix ("apple" matches "apples")
            if len(kw) > best_len and re.search(r'\b' + re.escape(kw), lower):
                best_cat = category
                best_len = len(kw)
    return GroceryCategory(best_cat) if best_cat else GroceryCategory.other


class GroceryService:
    def __init__(self, supabase: Client = Depends(get_supabase)):
        self.db = supabase

    # ── Get Items ─────────────────────────────────────────────────────────────

    async def get_items(
        self,
        household_id: str,
        category: Optional[str] = None,
        is_checked: Optional[bool] = None,
    ) -> GroceryListResponse:
        """
        Fetch all grocery items for household.
        Unchecked items first, then checked. Optional category + checked filters.
        """
        query = self.db.table("grocery_items").select(
            "*, profiles!grocery_items_added_by_fkey"
            "(id, full_name, initials, avatar_url)"
        ).eq("household_id", household_id)

        if category:
            query = query.eq("category", category)
        if is_checked is not None:
            query = query.eq("is_checked", is_checked)

        result = query.order("is_checked").order("created_at").execute()
        items = [self._format_item(i) for i in result.data]

        checked   = sum(1 for i in items if i.is_checked)
        unchecked = sum(1 for i in items if not i.is_checked)

        return GroceryListResponse(
            items=items,
            total=len(items),
            checked=checked,
            unchecked=unchecked,
        )

    # ── Add Item ──────────────────────────────────────────────────────────────

    async def add_item(
        self,
        body: AddGroceryItemRequest,
        user_id: str,
        household_id: str,
    ) -> GroceryItemResponse:
        """
        1. Infer category if not provided
        2. Insert item row
        3. Broadcast grocery:item_added
        4. Return item with added_by profile
        """
        category = body.category or infer_category(body.name)

        item_id = str(uuid.uuid4())
        self.db.table("grocery_items").insert({
            "id": item_id,
            "household_id": household_id,
            "name": body.name,
            "category": category.value,
            "quantity": body.quantity,
            "note": body.note,
            "brand": body.brand,
            "is_checked": False,
            "added_by": user_id,
        }).execute()

        item = await self._get_item_with_profile(item_id)
        await ws_manager.broadcast(
            household_id, "grocery:item_added", item.model_dump()
        )
        return item

    # ── Update Item ───────────────────────────────────────────────────────────

    async def update_item(
        self,
        item_id: str,
        household_id: str,
        body: UpdateGroceryItemRequest,
    ) -> GroceryItemResponse:
        """Update item details. Re-infers category if name changes and category not explicitly set."""
        await self._verify_item(item_id, household_id)

        update_data = {}
        if body.name is not None:
            update_data["name"] = body.name
            if body.category is None:
                # Re-infer category when name changes
                update_data["category"] = infer_category(body.name).value
        if body.quantity is not None:
            update_data["quantity"] = body.quantity
        if body.note is not None:
            update_data["note"] = body.note
        if body.brand is not None:
            update_data["brand"] = body.brand
        if body.category is not None:
            update_data["category"] = body.category.value

        if update_data:
            self.db.table("grocery_items").update(update_data).eq(
                "id", item_id
            ).execute()

        item = await self._get_item_with_profile(item_id)
        await ws_manager.broadcast(
            household_id, "grocery:item_updated", item.model_dump()
        )
        return item

    # ── Toggle Checked ────────────────────────────────────────────────────────

    async def toggle_item(
        self, item_id: str, household_id: str
    ) -> GroceryItemResponse:
        """
        Toggle item checked state. Idempotent.
        Sets checked_at on check, clears it on uncheck.
        Broadcasts grocery:item_toggled.
        """
        result = self.db.table("grocery_items").select(
            "id, is_checked"
        ).eq("id", item_id).eq("household_id", household_id).single().execute()

        if not result.data:
            raise FamilySyncException(404, "Grocery item not found")

        new_state = not result.data["is_checked"]

        self.db.table("grocery_items").update({
            "is_checked": new_state,
            "checked_at": (
                datetime.now(timezone.utc).isoformat() if new_state else None
            ),
        }).eq("id", item_id).execute()

        item = await self._get_item_with_profile(item_id)
        await ws_manager.broadcast(
            household_id, "grocery:item_toggled", item.model_dump()
        )
        return item

    # ── Delete Item ───────────────────────────────────────────────────────────

    async def delete_item(self, item_id: str, household_id: str) -> None:
        """Delete single item. Broadcasts grocery:item_deleted."""
        await self._verify_item(item_id, household_id)
        self.db.table("grocery_items").delete().eq("id", item_id).execute()
        await ws_manager.broadcast(
            household_id, "grocery:item_deleted", {"item_id": item_id}
        )

    # ── Clear Checked ─────────────────────────────────────────────────────────

    async def clear_checked(self, household_id: str) -> GroceryListResponse:
        """
        Delete all checked items at once.
        Broadcasts grocery:cleared_checked with list of deleted IDs.
        Returns updated full list.
        """
        checked = self.db.table("grocery_items").select("id").eq(
            "household_id", household_id
        ).eq("is_checked", True).execute()

        if not checked.data:
            return await self.get_items(household_id)

        ids_to_delete = [i["id"] for i in checked.data]

        self.db.table("grocery_items").delete().eq(
            "household_id", household_id
        ).eq("is_checked", True).execute()

        await ws_manager.broadcast(
            household_id,
            "grocery:cleared_checked",
            {"deleted_ids": ids_to_delete},
        )

        return await self.get_items(household_id)

    # ── Offline Batch Sync ────────────────────────────────────────────────────

    async def batch_sync(
        self,
        body: BatchSyncRequest,
        user_id: str,
        household_id: str,
    ) -> BatchSyncResponse:
        """
        Sync items created offline in Flutter's Isar queue.
        Uses local_id as idempotency key — safe to call multiple times.
        Returns local_id → server_id mapping for Flutter to update Isar.
        """
        synced = 0
        failed = 0
        id_map = []

        for item in body.items:
            try:
                # Check if already synced via local_id (idempotency)
                existing = self.db.table("grocery_items").select("id").eq(
                    "local_id", item.local_id
                ).eq("household_id", household_id).execute()

                if existing.data:
                    id_map.append({
                        "local_id": item.local_id,
                        "server_id": existing.data[0]["id"],
                    })
                    synced += 1
                    continue

                category = item.category or infer_category(item.name)
                server_id = str(uuid.uuid4())

                self.db.table("grocery_items").insert({
                    "id": server_id,
                    "local_id": item.local_id,
                    "household_id": household_id,
                    "name": item.name,
                    "category": category.value,
                    "quantity": item.quantity,
                    "note": item.note,
                    "brand": item.brand,
                    "is_checked": item.is_checked,
                    "added_by": user_id,
                    "created_at": item.created_at,
                }).execute()

                id_map.append({
                    "local_id": item.local_id,
                    "server_id": server_id,
                })
                synced += 1

            except Exception:
                failed += 1

        if synced > 0:
            full_list = await self.get_items(household_id)
            await ws_manager.broadcast(
                household_id,
                "grocery:list_refreshed",
                {"items": [i.model_dump() for i in full_list.items]},
            )

        return BatchSyncResponse(synced=synced, failed=failed, item_ids=id_map)

    # ── Private Helpers ───────────────────────────────────────────────────────

    async def _verify_item(self, item_id: str, household_id: str) -> None:
        result = self.db.table("grocery_items").select("id").eq(
            "id", item_id
        ).eq("household_id", household_id).execute()
        if not result.data:
            raise FamilySyncException(404, "Grocery item not found")

    async def _get_item_with_profile(self, item_id: str) -> GroceryItemResponse:
        result = self.db.table("grocery_items").select(
            "*, profiles!grocery_items_added_by_fkey"
            "(id, full_name, initials, avatar_url)"
        ).eq("id", item_id).single().execute()
        return self._format_item(result.data)

    def _format_item(self, i: dict) -> GroceryItemResponse:
        profile = i.get("profiles") or {}
        added_by_member = AddedByResponse(
            id=profile.get("id", ""),
            full_name=profile.get("full_name", ""),
            initials=profile.get("initials", ""),
            avatar_url=profile.get("avatar_url"),
        ) if profile else None

        return GroceryItemResponse(
            id=i["id"],
            household_id=i["household_id"],
            name=i["name"],
            category=i.get("category", "other"),
            quantity=i.get("quantity", "×1"),
            note=i.get("note"),
            brand=i.get("brand"),
            is_checked=i.get("is_checked", False),
            checked_at=i.get("checked_at"),
            added_by=i["added_by"],
            added_by_member=added_by_member,
            created_at=i.get("created_at", ""),
        )
