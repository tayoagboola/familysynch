from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import Optional

from ..auth import CurrentUser
from ..database import get_supabase

router = APIRouter(prefix="/grocery", tags=["grocery"])


class GroceryItemRequest(BaseModel):
    name: str
    quantity: Optional[str] = None
    category: Optional[str] = None
    added_by: Optional[str] = None


class GroceryItemResponse(BaseModel):
    id: str
    household_id: str
    name: str
    quantity: Optional[str] = None
    category: Optional[str] = None
    checked: bool
    added_by: str
    checked_by: Optional[str] = None


def _assert_member(db, household_id: str, user_id: str):
    result = (
        db.table("household_members")
        .select("id")
        .eq("household_id", household_id)
        .eq("user_id", user_id)
        .maybe_single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=403, detail="Not a member of this household")


@router.get("/{household_id}/items", response_model=list[GroceryItemResponse])
def list_items(household_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = (
        db.table("grocery_items")
        .select("*")
        .eq("household_id", household_id)
        .order("category")
        .execute()
    )
    return result.data or []


@router.post("/{household_id}/items", response_model=GroceryItemResponse, status_code=status.HTTP_201_CREATED)
def add_item(household_id: str, body: GroceryItemRequest, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    result = db.table("grocery_items").insert({
        "household_id": household_id,
        "name": body.name,
        "quantity": body.quantity,
        "category": body.category,
        "checked": False,
        "added_by": user["sub"],
    }).execute()

    if not result.data:
        raise HTTPException(status_code=500, detail="Failed to add item")
    return result.data[0]


@router.patch("/{household_id}/items/{item_id}/check", response_model=GroceryItemResponse)
def toggle_check(household_id: str, item_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    existing = (
        db.table("grocery_items")
        .select("id, checked")
        .eq("id", item_id)
        .eq("household_id", household_id)
        .maybe_single()
        .execute()
    )
    if not existing.data:
        raise HTTPException(status_code=404, detail="Item not found")

    checked = not existing.data["checked"]
    result = db.table("grocery_items").update({
        "checked": checked,
        "checked_by": user["sub"] if checked else None,
    }).eq("id", item_id).execute()
    return result.data[0]


@router.delete("/{household_id}/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(household_id: str, item_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    db.table("grocery_items").delete().eq("id", item_id).eq("household_id", household_id).execute()


@router.delete("/{household_id}/items/checked", status_code=status.HTTP_204_NO_CONTENT)
def clear_checked(household_id: str, user: CurrentUser):
    db = get_supabase()
    _assert_member(db, household_id, user["sub"])

    db.table("grocery_items").delete().eq("household_id", household_id).eq("checked", True).execute()
