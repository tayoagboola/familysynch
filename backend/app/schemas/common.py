from typing import Generic, Optional, TypeVar
from pydantic import BaseModel

T = TypeVar("T")


class SuccessResponse(BaseModel, Generic[T]):
    """Standard success envelope: {"success": true, "data": {...}}"""
    success: bool = True
    data: T


class MessageResponse(BaseModel):
    """Standard message envelope: {"success": true, "message": "..."}"""
    success: bool = True
    message: str


class ErrorResponse(BaseModel):
    """Standard error envelope: {"error": "..."}"""
    error: str
