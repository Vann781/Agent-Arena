from datetime import datetime, timezone

from backend.core.exceptions import DebateNotFoundError, VoteAlreadyExistsError
from backend.models.debate import Vote
from backend.services.storage import create_document, get_document, query_collection
from backend.utils.helpers import generate_id

COLLECTION = "votes"


def cast_vote(debate_id: str, session_id: str, choice: str) -> Vote:
    existing = get_document(COLLECTION, f"{debate_id}_{session_id}")
    if existing:
        raise VoteAlreadyExistsError(debate_id, session_id)
    vote = Vote(
        id=f"{debate_id}_{session_id}",
        debate_id=debate_id,
        session_id=session_id,
        choice=choice,
        created_at=datetime.now(timezone.utc).isoformat(),
    )
    create_document(COLLECTION, vote.id, vote.model_dump())
    return vote


def get_results(debate_id: str) -> dict:
    votes = query_collection(COLLECTION)
    debate_votes = [v for v in votes if v["debate_id"] == debate_id]
    pro_count = sum(1 for v in debate_votes if v["choice"] == "pro")
    con_count = sum(1 for v in debate_votes if v["choice"] == "con")
    return {"debate_id": debate_id, "pro": pro_count, "con": con_count, "total": len(debate_votes)}
