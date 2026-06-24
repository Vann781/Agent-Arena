from langgraph.graph import END, StateGraph

from backend.langgraph.nodes import generate_con_argument, generate_pro_argument, judge_round
from backend.langgraph.router import should_continue
from backend.langgraph.state import DebateState


def build_debate_graph() -> StateGraph:
    workflow = StateGraph(DebateState)

    workflow.add_node("pro", generate_pro_argument)
    workflow.add_node("con", generate_con_argument)
    workflow.add_node("judge", judge_round)

    workflow.set_entry_point("pro")
    workflow.add_edge("pro", "con")
    workflow.add_edge("con", "judge")
    workflow.add_conditional_edges("judge", should_continue, {"continue": "pro", "end": END})

    return workflow.compile()


debate_graph = build_debate_graph()
