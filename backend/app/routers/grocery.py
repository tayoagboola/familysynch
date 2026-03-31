"""
Grocery Router — /grocery prefix
All endpoints require authentication + household membership.
WebSocket broadcasts happen inside service layer on every mutation.
IMPORTANT: DELETE /checked must be registered BEFORE DELETE /{item_id}
to avoid FastAPI treating "checked" as an item_id path parameter.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query

from app.core.dependencies import require_household
from app.schemas.common import MessageResponse, SuccessResponse
from app.schemas.grocery import (
    AddGroceryItemRequest,
    BatchSyncRequest,
    BatchSyncResponse,
    GroceryItemResponse,
    GroceryListResponse,
    UpdateGroceryItemRequest,
)
from app.services.grocery_service import GroceryService

router = APIRouter(prefix="/grocery", tags=["grocery"])


@router.get("", response_model=SuccessResponse[GroceryListResponse])
async def get_items(
    category: Optional[str] = Query(None, description="dairy|produce|meat|care|bakery|frozen|drinks|other"),
    is_checked: Optional[bool] = Query(None, description="Filter by checked state"),
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """Get all grocery items. Unchecked first, then checked."""
    result = await service.get_items(
        current_user["household_id"], category, is_checked
    )
    return SuccessResponse(data=result)


@router.post("", response_model=SuccessResponse[GroceryItemResponse])
async def add_item(
    body: AddGroceryItemRequest,
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """Add item. Category inferred from name if not provided."""
    result = await service.add_item(
        body, current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.post("/sync", response_model=SuccessResponse[BatchSyncResponse])
async def batch_sync(
    body: BatchSyncRequest,
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """
    Offline sync — Flutter calls this on reconnect.
    Sends Isar pending queue → returns local_id to server_id mapping.
    Idempotent via local_id — safe to call multiple times.
    """
    result = await service.batch_sync(
        body, current_user["id"], current_user["household_id"]
    )
    return SuccessResponse(data=result)


@router.delete("/checked", response_model=SuccessResponse[GroceryListResponse])
async def clear_checked(
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """
    Delete all checked items at once.
    Registered before DELETE /{item_id} to avoid route conflict.
    """
    result = await service.clear_checked(current_user["household_id"])
    return SuccessResponse(data=result)


@router.put("/{item_id}", response_model=SuccessResponse[GroceryItemResponse])
async def update_item(
    item_id: str,
    body: UpdateGroceryItemRequest,
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """Update item details. Category re-inferred if name changes."""
    result = await service.update_item(
        item_id, current_user["household_id"], body
    )
    return SuccessResponse(data=result)


@router.post("/{item_id}/toggle", response_model=SuccessResponse[GroceryItemResponse])
async def toggle_item(
    item_id: str,
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """Toggle item checked state. Idempotent."""
    result = await service.toggle_item(item_id, current_user["household_id"])
    return SuccessResponse(data=result)


@router.delete("/{item_id}", response_model=MessageResponse)
async def delete_item(
    item_id: str,
    current_user: dict = Depends(require_household),
    service: GroceryService = Depends(GroceryService),
):
    """Delete single item."""
    await service.delete_item(item_id, current_user["household_id"])
    return MessageResponse(message="Item deleted")
