import logging
import re

from backend.config import settings

logger = logging.getLogger(__name__)

_use_mock = False

# Keys that mean "no real key configured"
_PLACEHOLDER_KEYS = {"", "your_gemini_api_key_here", "changeme", "none"}

# Livelier, more varied banter than the default deterministic output.
_GENERATION_CONFIG = {
    "temperature": 0.95,
    "top_p": 0.95,
    "max_output_tokens": 256,
}


def init_gemini():
    global _use_mock
    key = (settings.gemini_api_key or "").strip()
    if key.lower() in _PLACEHOLDER_KEYS:
        _use_mock = True
        logger.warning(
            "GEMINI_API_KEY is not set — running in MOCK mode. Agents will use "
            "placeholder text and will NOT really debate the topic. Set GEMINI_API_KEY "
            "in your .env (locally) or in your host's environment variables (e.g. Render) "
            "to enable real debates."
        )
        return
    try:
        import google.generativeai as genai
        genai.configure(api_key=key)
        _use_mock = False
        logger.info("Gemini API configured (model=%s)", settings.gemini_model)
    except Exception as e:
        _use_mock = True
        logger.warning("Gemini init failed (%s); using mock responses", e)


def generate_text(prompt: str) -> str:
    global _use_mock
    if _use_mock:
        return _mock_response(prompt)
    try:
        import google.generativeai as genai
        model = genai.GenerativeModel(settings.gemini_model)
        response = model.generate_content(
            prompt,
            generation_config=_GENERATION_CONFIG,
        )
        text = (getattr(response, "text", "") or "").strip()
        if not text:
            logger.warning("Gemini returned empty text; using mock for this turn")
            return _mock_response(prompt)
        return text
    except Exception as e:
        # Don't permanently latch to mock on a single transient error; just
        # fall back for THIS turn and let the next call try again.
        logger.warning("Gemini API call failed (%s); using mock for this turn", e)
        return _mock_response(prompt)


# ---------------------------------------------------------------------------
# Fallback mock. This is only used when no API key is configured (or a call
# fails). It is intentionally topic-aware and varies per round so the app
# stays usable for a demo — but it is NOT a real debate. Set GEMINI_API_KEY
# for genuine arguments.
# ---------------------------------------------------------------------------

def _extract(prompt: str, label: str) -> str:
    m = re.search(rf"{label}:\s*(.+)", prompt)
    return m.group(1).strip() if m else ""


def _round_no(prompt: str) -> int:
    m = re.search(r"Round\s+(\d+)", prompt)
    return int(m.group(1)) if m else 1


_PRO_LINES = [
    '"{topic}" — obvious winner, and you know it. {opp_jab} [aggressive]',
    'Simple: "{topic}" wins on every count that matters. Your last point? Weak sauce. [serious]',
    'I keep landing clean hits for "{topic}" while you swing at air. {opp_jab} [sarcastic]',
]

_CON_LINES = [
    'Cute speech, but "{topic}" falls apart the second you poke it. {opp_jab} [sarcastic]',
    'Nah. "{topic}" sounds nice until you think for two seconds. Try again. [aggressive]',
    'You\'re defending "{topic}" like it owes you money. It doesn\'t hold up. {opp_jab} [serious]',
]


def _mock_response(prompt: str) -> str:
    role = _extract(prompt, "ROLE").upper()
    topic = _extract(prompt, "Topic") or "this topic"
    rn = _round_no(prompt)

    if role == "JUDGE" or "judge" in prompt.lower():
        pro_s = 6 + (rn % 3)
        con_s = 5 + ((rn + 1) % 3)
        return (
            f"Commentary: Round {rn} on \"{topic}\" was a scrap! Both sides threw hands.\n"
            f"Pro Score: {pro_s}/10\n"
            f"Con Score: {con_s}/10"
        )

    if role == "CON":
        opp_jab = "That \"strong\" argument? I've dodged stiffer breezes."
        return _CON_LINES[rn % len(_CON_LINES)].format(topic=topic, opp_jab=opp_jab)

    # default to PRO
    opp_jab = "Is that your best shot? My grandma counters harder."
    return _PRO_LINES[rn % len(_PRO_LINES)].format(topic=topic, opp_jab=opp_jab)