from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from backend.core.exceptions import DebateCompletedError, DebateNotFoundError, VoteAlreadyExistsError
from backend.models.debate import DebateRound
from backend.services.debate_service import add_round, create_debate, get_debate
from backend.services.vote_service import cast_vote, get_results
from backend.langgraph.graph import debate_graph
from backend.langgraph.state import DebateState

router = APIRouter()


class StartDebateRequest(BaseModel):
    topic: str
    description: str
    max_rounds: int = 3


class NextRoundRequest(BaseModel):
    debate_id: str


class VoteRequest(BaseModel):
    debate_id: str
    session_id: str
    choice: str


@router.post("/start")
def start_debate(req: StartDebateRequest):
    debate = create_debate(req.topic, req.description, req.max_rounds)
    return {"debate_id": debate.id, "topic": debate.topic, "status": debate.status}


@router.get("/{debate_id}")
def get_debate_status(debate_id: str):
    try:
        debate = get_debate(debate_id)
        return debate.model_dump()
    except DebateNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/next-round")
def next_round(req: NextRoundRequest):
    try:
        debate = get_debate(req.debate_id)
    except DebateNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))

    if debate.status != "in_progress":
        raise HTTPException(status_code=400, detail="Debate already completed")

    initial: DebateState = {
        "topic": debate.topic,
        "description": debate.description,
        "max_rounds": debate.max_rounds,
        "current_round": debate.current_round,
        "pro_argument": "",
        "con_argument": "",
        "judge_feedback": "",
        "score_pro": 0.0,
        "score_con": 0.0,
        "winner": "",
        "rounds_history": [r.model_dump() for r in debate.rounds],
    }

    result = debate_graph.invoke(initial)

    round_data = DebateRound(
        round_number=result["current_round"] + 1,
        pro_argument=result["pro_argument"],
        pro_tone=result.get("pro_tone", "serious"),
        con_argument=result["con_argument"],
        con_tone=result.get("con_tone", "serious"),
        judge_feedback=result["judge_feedback"],
        score_pro=result["score_pro"],
        score_con=result["score_con"],
    )

    updated = add_round(req.debate_id, round_data)
    return updated.model_dump()


@router.post("/vote")
def vote(req: VoteRequest):
    try:
        vote = cast_vote(req.debate_id, req.session_id, req.choice)
        return vote.model_dump()
    except (DebateNotFoundError, VoteAlreadyExistsError) as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{debate_id}/results")
def debate_results(debate_id: str):
    try:
        get_debate(debate_id)
    except DebateNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    return get_results(debate_id)
