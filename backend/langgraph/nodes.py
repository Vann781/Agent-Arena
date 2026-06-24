from backend.langgraph.state import DebateState
from backend.services.gemini_service import generate_text

PRO_SYSTEM = "You are an expert debater arguing FOR the following topic. Provide a concise, persuasive argument."
CON_SYSTEM = "You are an expert debater arguing AGAINST the following topic. Provide a concise, persuasive argument."
JUDGE_SYSTEM = "You are an impartial judge. Evaluate both arguments, provide feedback, and score each out of 10."


def generate_pro_argument(state: DebateState) -> dict:
    prompt = f"{PRO_SYSTEM}\n\nTopic: {state['topic']}\n{state['description']}\n\nRound {state['current_round'] + 1}:\n"
    if state.get("con_argument"):
        prompt += f"Opponent's argument: {state['con_argument']}\n\nRespond to the opponent's argument:"
    result = generate_text(prompt)
    return {"pro_argument": result}


def generate_con_argument(state: DebateState) -> dict:
    prompt = f"{CON_SYSTEM}\n\nTopic: {state['topic']}\n{state['description']}\n\nRound {state['current_round'] + 1}:\n"
    if state.get("pro_argument"):
        prompt += f"Opponent's argument: {state['pro_argument']}\n\nRespond to the opponent's argument:"
    result = generate_text(prompt)
    return {"con_argument": result}


def judge_round(state: DebateState) -> dict:
    prompt = (
        f"{JUDGE_SYSTEM}\n\nTopic: {state['topic']}\n\n"
        f"Pro Argument (Round {state['current_round'] + 1}):\n{state['pro_argument']}\n\n"
        f"Con Argument:\n{state['con_argument']}\n\n"
        "Provide feedback and scores (pro score, con score) in format:\n"
        "Feedback: ...\nPro Score: X/10\nCon Score: Y/10"
    )
    result = generate_text(prompt)
    feedback = result
    pro_score = 5.0
    con_score = 5.0
    for line in result.split("\n"):
        lower = line.lower()
        if "pro score" in lower:
            try:
                pro_score = float(line.split(":")[1].strip().split("/")[0])
            except (ValueError, IndexError):
                pass
        elif "con score" in lower:
            try:
                con_score = float(line.split(":")[1].strip().split("/")[0])
            except (ValueError, IndexError):
                pass
    round_entry = {
        "round_number": state["current_round"] + 1,
        "pro_argument": state["pro_argument"],
        "con_argument": state["con_argument"],
        "judge_feedback": feedback,
        "score_pro": pro_score,
        "score_con": con_score,
    }
    return {
        "judge_feedback": feedback,
        "score_pro": pro_score,
        "score_con": con_score,
        "current_round": state["current_round"] + 1,
        "rounds_history": [*state.get("rounds_history", []), round_entry],
    }
