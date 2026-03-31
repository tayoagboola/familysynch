from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from app.core.config import settings
from app.core.exceptions import FamilySyncException
from app.routers.auth import router as auth_router
from app.routers.auth import limiter
from app.routers.household import router as household_router
from app.routers.calendar import router as calendar_router
from app.routers.tasks import router as tasks_router
from app.routers.grocery import router as grocery_router
from app.routers.feed import router as feed_router
from app.routers.kid import router as kid_router
from app.routers.ai import router as ai_router
from app.routers.notifications import router as notifications_router
from app.routers.jobs import router as jobs_router

app = FastAPI(
    title="FamilySync API",
    version="1.0.0",
    description="Family productivity backend — Flutter never touches Supabase directly.",
)

# ── CORS ──────────────────────────────────────────────────────────────────────

origins = (
    settings.allowed_origins.split(",")
    if settings.allowed_origins != "*"
    else ["*"]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Rate limiting ─────────────────────────────────────────────────────────────

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# ── Global error handler ──────────────────────────────────────────────────────

@app.exception_handler(FamilySyncException)
async def familysync_exception_handler(request: Request, exc: FamilySyncException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.detail},
    )

# ── Routers ───────────────────────────────────────────────────────────────────

app.include_router(auth_router)
app.include_router(household_router)
app.include_router(calendar_router)
app.include_router(tasks_router)
app.include_router(grocery_router)
app.include_router(feed_router)
app.include_router(kid_router)
app.include_router(ai_router)
app.include_router(notifications_router)
app.include_router(jobs_router)

# Additional routers registered here as each service is built:
# app.include_router(feed_router)
# app.include_router(kid_router)
# app.include_router(ai_router)
# app.include_router(notifications_router)
# app.include_router(jobs_router)
# app.include_router(realtime_router)   # WebSocket endpoints

# ── Health ────────────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "env": settings.app_env}
