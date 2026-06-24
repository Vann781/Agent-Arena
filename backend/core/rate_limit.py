import time
from collections import defaultdict

from backend.config import settings


class InMemoryRateLimiter:
    def __init__(self):
        self._requests: dict[str, list[float]] = defaultdict(list)

    def check(self, key: str) -> bool:
        now = time.time()
        window = 60.0
        self._requests[key] = [t for t in self._requests[key] if now - t < window]
        if len(self._requests[key]) >= settings.rate_limit_per_minute:
            return False
        self._requests[key].append(now)
        return True


rate_limiter = InMemoryRateLimiter()
