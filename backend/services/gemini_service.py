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
    if "arguing for" in prompt_lower or "pro" in prompt_lower:
        return (
            "Thank you for that opportunity. I firmly believe that this topic has "
            "significant merit and should be supported. The evidence clearly shows "
            "positive outcomes when this approach is adopted. We must consider the "
            "long-term benefits and the progressive impact it will have on society. "
            "The data overwhelmingly supports this position, and I encourage everyone "
            "to look at the empirical evidence."
        )
    elif "arguing against" in prompt_lower or "con" in prompt_lower:
        return (
            "I respectfully disagree with the previous speaker. While the arguments "
            "presented may sound appealing, they overlook critical flaws. The negative "
            "consequences far outweigh any potential benefits. We need to consider the "
            "ethical implications and the practical challenges that make this approach "
            "problematic. History has shown us that hasty adoption leads to regret."
        )
    elif "judge" in prompt_lower:
        return (
            "Feedback: Both sides presented compelling arguments. The pro side made "
            "strong points about potential benefits and cited relevant evidence. The "
            "con side raised important concerns about implementation challenges.\n"
            "Pro Score: 7/10\n"
            "Con Score: 6/10"
        )
    return "This is a well-reasoned argument with supporting evidence."
