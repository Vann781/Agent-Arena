from typing import TypedDict


class DebateState(TypedDict):
    topic: str
    description: str
    max_rounds: int
    current_round: int
    pro_argument: str
    con_argument: str
    judge_feedback: str
    score_pro: float
    score_con: float
    winner: str
    rounds_history: list[dict]
