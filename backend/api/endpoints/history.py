from fastapi import APIRouter

from backend.services.debate_service import get_debate, list_debates

router = APIRouter()


@router.get("")
def list_history(limit: int = 20):
    debates = list_debates(limit)
    return [d.model_dump() for d in debates]


@router.get("/{debate_id}")
def get_history(debate_id: str):
    debate = get_debate(debate_id)
    return debate.model_dump()
