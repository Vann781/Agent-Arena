from backend.config import settings


def get_allowed_origins() -> list[str]:
    return [o.strip() for o in settings.allowed_origins.split(",") if o.strip()]
