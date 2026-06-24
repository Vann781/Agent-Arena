from backend.api.endpoints.debate import router as debate_router
from backend.api.endpoints.health import router as health_router
from backend.api.endpoints.history import router as history_router

__all__ = ["health_router", "debate_router", "history_router"]
