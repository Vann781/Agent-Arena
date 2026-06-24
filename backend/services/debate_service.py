from datetime import datetime, timezone

from backend.core.exceptions import DebateCompletedError, DebateNotFoundError
from backend.models.debate import DebateRound, DebateSession
from backend.services.storage import create_document, get_document, query_collection, update_document
from backend.utils.helpers import generate_id

COLLECTION = "debates"


def create_debate(topic: str, description: str, max_rounds: int = 3) -> DebateSession:
    now = datetime.now(timezone.utc).isoformat()
    debate = DebateSession(
        id=generate_id(),
        topic=topic,
        description=description,
        max_rounds=max_rounds,
        current_round=0,
        rounds=[],
        status="in_progress",
        winner=None,
        created_at=now,
        updated_at=now,
    )
    create_document(COLLECTION, debate.id, debate.model_dump())
    return debate


def get_debate(debate_id: str) -> DebateSession:
    data = get_document(COLLECTION, debate_id)
    if not data:
        raise DebateNotFoundError(debate_id)
    return DebateSession(**data)


def add_round(debate_id: str, round_data: DebateRound) -> DebateSession:
    debate = get_debate(debate_id)
    if debate.status != "in_progress":
        raise DebateCompletedError(debate_id)
    debate.rounds.append(round_data)
    debate.current_round = round_data.round_number
    debate.updated_at = datetime.now(timezone.utc).isoformat()
    if round_data.round_number >= debate.max_rounds:
        debate.status = "completed"
        debate.winner = "pro" if round_data.score_pro > round_data.score_con else "con"
    update_document(COLLECTION, debate_id, debate.model_dump())
    return debate


def list_debates(limit: int = 20) -> list[DebateSession]:
    docs = query_collection(COLLECTION, order_by="created_at", limit=limit)
    return [DebateSession(**d) for d in docs]
