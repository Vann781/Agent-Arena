from backend.langgraph.state import DebateState
from backend.services.gemini_service import generate_text

PRO_SYSTEM = (
    "You are an AGGRESSIVE fighter debating FOR the topic. You talk like a cocky street brawler. "
    "Keep responses SHORT — 1-2 sentences max. Throw insults, use fighting metaphors, be hyped. "
    "End your response with a tone tag: [sarcastic], [serious], or [aggressive]."
)

CON_SYSTEM = (
    "You are a SNARKY counter-fighter arguing AGAINST the topic. You talk like a slick defensive fighter. "
    "Keep responses SHORT — 1-2 sentences max. Mock your opponent, use fighting metaphors, be witty. "
    "End your response with a tone tag: [sarcastic], [serious], or [aggressive]."
)

JUDGE_SYSTEM = (
    "You are an EXCITED fight commentator. Give a hype评语 about the round. "
    "Scores are out of 10. Keep it short. Format:\n"
    "Commentary: ...\n"
    "Pro Score: X/10\n"
    "Con Score: Y/10"
)


def generate_pro_argument(state: DebateState) -> dict:
    con_prev = state.get("con_argument", "")
    prompt = (
        f"{PRO_SYSTEM}\n\nTopic: {state['topic']}\n"
        f"Round {state['current_round'] + 1} — FIGHT!\n"
    )
    if con_prev:
        prompt += f"Opponent just said: \"{con_prev}\"\n\nSmash that argument!"
    else:
        prompt += "Open with a strong attack!\n"
    result = generate_text(prompt)
    tone = "aggressive"
    for t in ["[sarcastic]", "[serious]", "[aggressive]"]:
        if t in result:
            tone = t.strip("[]")
            result = result.replace(t, "").strip()
    return {"pro_argument": result, "pro_tone": tone}


def generate_con_argument(state: DebateState) -> dict:
    prompt = (
        f"{CON_SYSTEM}\n\nTopic: {state['topic']}\n"
        f"Round {state['current_round'] + 1} — COUNTER!\n"
        f"They said: \"{state.get('pro_argument', '')}\"\n\n"
        "Dodge and counter-attack!\n"
    )
    result = generate_text(prompt)
    tone = "sarcastic"
    for t in ["[sarcastic]", "[serious]", "[aggressive]"]:
        if t in result:
            tone = t.strip("[]")
            result = result.replace(t, "").strip()
    return {"con_argument": result, "con_tone": tone}


def judge_round(state: DebateState) -> dict:
    prompt = (
        f"{JUDGE_SYSTEM}\n\nTopic: {state['topic']}\n\n"
        f"🔥 PRO (Round {state['current_round'] + 1}):\n{state['pro_argument']}\n\n"
        f"💧 CON (Round {state['current_round'] + 1}):\n{state['con_argument']}\n\n"
        "Who won this round?\n"
    )
    result = generate_text(prompt)
    commentary = result
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
        "pro_tone": state.get("pro_tone", "serious"),
        "con_argument": state["con_argument"],
        "con_tone": state.get("con_tone", "serious"),
        "judge_feedback": commentary,
        "score_pro": pro_score,
        "score_con": con_score,
    }
    return {
        "judge_feedback": commentary,
        "score_pro": pro_score,
        "score_con": con_score,
        "current_round": state["current_round"] + 1,
        "rounds_history": [*state.get("rounds_history", []), round_entry],
    }
