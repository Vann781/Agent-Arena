from enum import StrEnum
from pydantic import BaseModel


class AgentType(StrEnum):
    PRO = "pro"
    CON = "con"
    JUDGE = "judge"


class DebateRound(BaseModel):
    round_number: int
    pro_argument: str
    con_argument: str
    judge_feedback: str
    score_pro: float
    score_con: float


class DebateSession(BaseModel):
    id: str
    topic: str
    description: str
    max_rounds: int
    current_round: int
    rounds: list[DebateRound]
    status: str
    winner: str | None
    created_at: str
    updated_at: str


class Vote(BaseModel):
    id: str
    debate_id: str
    session_id: str
    choice: str
    created_at: str
