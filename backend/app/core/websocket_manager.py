from fastapi import WebSocket
from typing import Dict, List
import json


class WebSocketManager:
    """
    Singleton — manages all active WebSocket connections.
    Connections are grouped by household_id.
    All mutation services call broadcast() after writing to Supabase.
    """

    def __init__(self):
        # { household_id: [WebSocket, ...] }
        self.connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, household_id: str):
        await websocket.accept()
        self.connections.setdefault(household_id, []).append(websocket)

    def disconnect(self, websocket: WebSocket, household_id: str):
        if household_id in self.connections:
            try:
                self.connections[household_id].remove(websocket)
            except ValueError:
                pass
            if not self.connections[household_id]:
                del self.connections[household_id]

    async def broadcast(self, household_id: str, event_type: str, data: dict):
        """Push update to every Flutter client in this household."""
        if household_id not in self.connections:
            return
        message = json.dumps({"event": event_type, "data": data})
        dead = []
        for ws in self.connections.get(household_id, []):
            try:
                await ws.send_text(message)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(ws, household_id)


# Global singleton — imported by all services and WebSocket routers
ws_manager = WebSocketManager()
