from backend.langgraph.state import DebateState


def should_continue(state: DebateState) -> str:
    if state["current_round"] >= state["max_rounds"] - 1:
        return "end"
    return "continue"
