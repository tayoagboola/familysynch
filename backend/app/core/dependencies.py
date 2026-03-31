from fastapi import Depends, Header
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.exceptions import FamilySyncException
from app.core.security import decode_token
from app.core.config import settings

_bearer = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer),
) -> dict:
    """
    Extracts and verifies the Bearer JWT from the Authorization header.
    Returns the token payload: {sub, household_id, type, exp}.
    Raises 401 if token is missing, expired, or invalid.
    """
    try:
        payload = decode_token(credentials.credentials)
    except ValueError:
        raise FamilySyncException(401, "Invalid or expired token")

    if payload.get("type") != "access":
        raise FamilySyncException(401, "Not an access token")

    # Normalise: always expose user id as "id" for convenience
    payload["id"] = payload["sub"]
    return payload


def require_household(
    current_user: dict = Depends(get_current_user),
) -> dict:
    """
    Same as get_current_user but additionally requires the user to belong
    to a household. Raises 403 if household_id is absent from the token.
    """
    if not current_user.get("household_id"):
        raise FamilySyncException(403, "You must belong to a household to perform this action")
    return current_user


def get_household_access(household_id: str, current_user: dict = Depends(require_household)) -> dict:
    """
    Verifies the authenticated user belongs to the given household_id path param.
    Raises 403 if the household_id in the token doesn't match.
    """
    if current_user["household_id"] != household_id:
        raise FamilySyncException(403, "Access denied to this household")
    return current_user


def verify_cron_secret(x_cron_secret: str = Header(...)) -> None:
    """
    Validates the cron secret header for /jobs/* endpoints.
    pg_cron sends this header on every HTTP POST to FastAPI.
    """
    if x_cron_secret != settings.cron_secret:
        raise FamilySyncException(403, "Invalid cron secret")
