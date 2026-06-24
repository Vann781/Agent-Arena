from backend.api.router import debate_router, health_router, history_router
from backend.config import settings
from backend.core.logging import setup_logging
from backend.core.security import get_allowed_origins
from backend.services.gemini_service import init_gemini
from backend.services.storage import init_storage
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging()
    init_storage()
    init_gemini()
    yield


app = FastAPI(
    title="Agent Arena API",
    description="Multi-agent AI debate platform",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=get_allowed_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router)
app.include_router(debate_router, prefix="/api/debate")
app.include_router(history_router, prefix="/api/history")
