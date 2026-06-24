import uuid
from datetime import datetime, timezone


def generate_id() -> str:
    return uuid.uuid4().hex[:16]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)
