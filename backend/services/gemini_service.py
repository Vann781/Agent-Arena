import logging

from backend.config import settings

logger = logging.getLogger(__name__)

_use_mock = False


def init_gemini():
    global _use_mock
    try:
        import google.generativeai as genai
        genai.configure(api_key=settings.gemini_api_key)
        _use_mock = False
        logger.info("Gemini API configured")
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
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        _use_mock = True
        logger.warning("Gemini API call failed (%s); switching to mock mode", e)
        return _mock_response(prompt)


def _mock_response(prompt: str) -> str:
    prompt_lower = prompt.lower()
    if "counter" in prompt_lower or "con" in prompt_lower:
        return (
            "Is that all you got? I've seen better arguments from a fortune cookie! "
            "You're swinging wild and missing everything. Come on, bring something real. "
            "This debate is already over. [sarcastic]"
        )
    elif "attack" in prompt_lower or "pro" in prompt_lower:
        return (
            "I'm coming at you like a freight train! This topic is obviously right "
            "and deep down you know it. There's no defense for your position. "
            "Take this L and walk away! [aggressive]"
        )
    elif "judge" in prompt_lower or "commentator" in prompt_lower:
        return (
            "Commentary: WHAT A ROUND! Both fighters came to throw down! The pro brought "
            "heat but the con's counter was slick and precise.\n"
            "Pro Score: 7/10\n"
            "Con Score: 6/10"
        )
    return "You're going down! I've barely warmed up yet. [aggressive]"
