from typing import TypedDict


class DebateState(TypedDict, total=False):
    topic: str
    description: str
    max_rounds: int
    current_round: int          # number of rounds already completed
    round_number: int           # the round being generated right now
    pro_argument: str
    pro_tone: str
    con_argument: str
    con_tone: str
    prev_pro_argument: str      # previous round's PRO line (for continuity)
    prev_con_argument: str      # previous round's CON line (for rebuttals)
    judge_feedback: str
    score_pro: float
    score_con: float
    winner: str
    rounds_history: list[dict]