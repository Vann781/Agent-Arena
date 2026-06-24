"""
Debate turn logic.

Each node runs ONCE per /next-round HTTP call (the graph is a single
pro -> con -> judge pass now; the frontend drives the rounds by calling
/next-round repeatedly). The endpoint owns round numbering, so the judge
node no longer increments current_round.

Key fixes vs the old version:
  * Prompts force the agent to (a) make a concrete point about the ACTUAL
    topic and (b) directly rebut the opponent's last line — not generic
    trash talk.
  * Agents reply in the SAME language/script as the topic, so a Hinglish
    topic ("vayu ya suraj") produces Hinglish banter.
  * A short transcript of previous rounds is passed in, so the debate
    builds over time instead of restarting every round.
"""

from backend.langgraph.state import DebateState
from backend.services.gemini_service import generate_text

TONE_TAGS = ["[sarcastic]", "[serious]", "[aggressive]"]

PRO_SYSTEM = (
    "You are PRO — a cocky street-fighter who argues FOR the topic.\n"
    "RULES:\n"
    "1. Make ONE concrete, specific point that actually supports the topic "
    "(real reasoning about the subject, not vague hype).\n"
    "2. Then directly mock or rebut the exact thing your opponent just said.\n"
    "3. 2-4 SHORT punchy sentences. Sound like a real person trash-talking.\n"
    "4. Reply in the SAME language and script as the Topic. If the topic mixes "
    "Hindi and English (Hinglish), reply in natural Hinglish.\n"
    "5. End with exactly ONE tone tag on its own: [sarcastic], [serious], or [aggressive]."
)

CON_SYSTEM = (
    "You are CON — a slick, snarky fighter who argues AGAINST the topic.\n"
    "RULES:\n"
    "1. Make ONE concrete, specific point against the topic (real reasoning).\n"
    "2. Then directly dodge and counter the exact thing PRO just said — name it, twist it.\n"
    "3. 2-4 SHORT sharp sentences with witty comebacks.\n"
    "4. Reply in the SAME language and script as the Topic. If the topic mixes "
    "Hindi and English (Hinglish), reply in natural Hinglish.\n"
    "5. End with exactly ONE tone tag on its own: [sarcastic], [serious], or [aggressive]."
)

JUDGE_SYSTEM = (
    "You are an EXCITED fight commentator scoring one round of a debate.\n"
    "Comment on what each side ACTUALLY said this round (reference their points). "
    "Reply in the same language as the topic. Keep it short. "
    "Scores are out of 10. Use exactly this format:\n"
    "Commentary: <one or two lines>\n"
    "Pro Score: X/10\n"
    "Con Score: Y/10"
)


def _transcript(state: DebateState, limit: int = 3) -> str:
    """Compact recap of the most recent rounds so agents can build on them."""
    history = state.get("rounds_history", []) or []
    if not history:
        return ""
    lines = ["Debate so far:"]
    for rnd in history[-limit:]:
        lines.append(f"Round {rnd.get('round_number', '?')}:")
        lines.append(f"  PRO: {rnd.get('pro_argument', '')}")
        lines.append(f"  CON: {rnd.get('con_argument', '')}")
    return "\n".join(lines) + "\n\n"


def _strip_tone(result: str, default: str) -> tuple[str, str]:
    tone = default
    for tag in TONE_TAGS:
        if tag.lower() in result.lower():
            tone = tag.strip("[]")
            # remove the tag case-insensitively
            idx = result.lower().find(tag.lower())
            result = (result[:idx] + result[idx + len(tag):]).strip()
    return result, tone


def generate_pro_argument(state: DebateState) -> dict:
    round_no = state.get("round_number", state.get("current_round", 0) + 1)
    prev_con = state.get("prev_con_argument", "") or state.get("con_argument", "")

    prompt = (
        f"{PRO_SYSTEM}\n\n"
        "ROLE: PRO\n"
        f"Topic: {state['topic']}\n"
        f"Round {round_no} — FIGHT!\n\n"
        f"{_transcript(state)}"
    )
    if prev_con:
        prompt += f'Opponent (CON) just said: "{prev_con}"\n\nSmash that argument and make your case!'
    else:
        prompt += "Open the debate with a strong, specific case FOR the topic!"

    result = generate_text(prompt)
    result, tone = _strip_tone(result, "aggressive")
    return {"pro_argument": result, "pro_tone": tone}


def generate_con_argument(state: DebateState) -> dict:
    round_no = state.get("round_number", state.get("current_round", 0) + 1)
    pro_now = state.get("pro_argument", "")

    prompt = (
        f"{CON_SYSTEM}\n\n"
        "ROLE: CON\n"
        f"Topic: {state['topic']}\n"
        f"Round {round_no} — COUNTER!\n\n"
        f"{_transcript(state)}"
        f'PRO just said: "{pro_now}"\n\n'
        "Dodge, counter-attack, and make your own case AGAINST the topic!"
    )

    result = generate_text(prompt)
    result, tone = _strip_tone(result, "sarcastic")
    return {"con_argument": result, "con_tone": tone}


def judge_round(state: DebateState) -> dict:
    round_no = state.get("round_number", state.get("current_round", 0) + 1)
    prompt = (
        f"{JUDGE_SYSTEM}\n\n"
        "ROLE: JUDGE\n"
        f"Topic: {state['topic']}\n\n"
        f"PRO (Round {round_no}): {state['pro_argument']}\n\n"
        f"CON (Round {round_no}): {state['con_argument']}\n\n"
        "Who won THIS round?"
    )
    result = generate_text(prompt)

    pro_score, con_score = 5.0, 5.0
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

    # NOTE: round numbering and persistence are handled by the endpoint.
    # This node only returns this round's verdict.
    return {
        "judge_feedback": result,
        "score_pro": pro_score,
        "score_con": con_score,
    }