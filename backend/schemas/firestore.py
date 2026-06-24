from pydantic import BaseModel


class DebateDocument(BaseModel):
    id: str
    topic: str
    description: str
    max_rounds: int
    current_round: int
    rounds: list[dict]
    status: str
    winner: str | None
    created_at: str
    updated_at: str


class VoteDocument(BaseModel):
    id: str
    debate_id: str
    session_id: str
    choice: str
    created_at: str
