from pydantic import BaseModel
from typing import Optional, List
from enum import Enum


class GroceryCategory(str, Enum):
    dairy   = "dairy"
    produce = "produce"
    meat    = "meat"
    care    = "care"
    bakery  = "bakery"
    frozen  = "frozen"
    drinks  = "drinks"
    other   = "other"


# ── Requests ──────────────────────────────────────────────────────────────────

class AddGroceryItemRequest(BaseModel):
    name: str
    quantity: str = "×1"
    note: Optional[str] = None
    brand: Optional[str] = None
    category: Optional[GroceryCategory] = None  # inferred if not provided


class UpdateGroceryItemRequest(BaseModel):
    name: Optional[str] = None
    quantity: Optional[str] = None
    note: Optional[str] = None
    brand: Optional[str] = None
    category: Optional[GroceryCategory] = None


class SyncGroceryItemRequest(BaseModel):
    """Single item from Flutter offline Isar queue."""
    local_id: str                           # Flutter-generated UUID while offline
    name: str
    quantity: str = "×1"
    note: Optional[str] = None
    brand: Optional[str] = None
    category: Optional[GroceryCategory] = None
    is_checked: bool = False
    created_at: str                         # original creation time on device


class BatchSyncRequest(BaseModel):
    """Offline sync payload — list of items created while offline."""
    items: List[SyncGroceryItemRequest]


# ── Responses ─────────────────────────────────────────────────────────────────

class AddedByResponse(BaseModel):
    id: str
    full_name: str
    initials: str
    avatar_url: Optional[str] = None


class GroceryItemResponse(BaseModel):
    id: str
    household_id: str
    name: str
    category: GroceryCategory
    quantity: str
    note: Optional[str] = None
    brand: Optional[str] = None
    is_checked: bool
    checked_at: Optional[str] = None
    added_by: str
    added_by_member: Optional[AddedByResponse] = None
    created_at: str


class GroceryListResponse(BaseModel):
    items: List[GroceryItemResponse]
    total: int
    checked: int
    unchecked: int


class BatchSyncResponse(BaseModel):
    synced: int
    failed: int
    item_ids: List[dict]            # [{"local_id": "...", "server_id": "..."}]
