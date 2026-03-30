from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import calendar, feed, grocery, households, notifications, tasks

app = FastAPI(title="FamilySync API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(households.router)
app.include_router(calendar.router)
app.include_router(tasks.router)
app.include_router(grocery.router)
app.include_router(feed.router)
app.include_router(notifications.router)


@app.get("/health")
def health():
    return {"status": "ok"}
