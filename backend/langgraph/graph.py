"""
Debate graph.

IMPORTANT CHANGE: the graph now runs exactly ONE round per invoke
(pro -> con -> judge -> END). It no longer loops internally.

Why: the Flutter app calls POST /api/debate/next-round once per round and
displays rounds.last each time. The old conditional edge made the graph
play the whole debate inside a single HTTP call, so only one round was ever
saved and the debate was marked "completed" immediately. The HTTP endpoint
is now the loop driver; completion is decided in debate_service.add_round
based on max_rounds.
"""

from langgraph.graph import END, StateGraph

from backend.langgraph.nodes import (
    generate_con_argument,
    generate_pro_argument,
    judge_round,
)
from backend.langgraph.state import DebateState


def build_debate_graph() -> StateGraph:
    workflow = StateGraph(DebateState)

    workflow.add_node("pro", generate_pro_argument)
    workflow.add_node("con", generate_con_argument)
    workflow.add_node("judge", judge_round)

    workflow.set_entry_point("pro")
    workflow.add_edge("pro", "con")
    workflow.add_edge("con", "judge")
    workflow.add_edge("judge", END)  # one round per invoke

    return workflow.compile()


debate_graph = build_debate_graph()