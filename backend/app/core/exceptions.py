from fastapi import HTTPException


class FamilySyncException(HTTPException):
    """
    Standard application exception.
    Raises an HTTP error with a JSON body: {"error": "message"}
    Usage: raise FamilySyncException(404, "User not found")
    """

    def __init__(self, status_code: int, detail: str):
        super().__init__(status_code=status_code, detail=detail)
