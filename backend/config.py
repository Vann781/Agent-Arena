from pathlib import Path
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.0-flash-lite"

    firebase_type: str = "service_account"
    firebase_project_id: str = ""
    firebase_private_key_id: str = ""
    firebase_private_key: str = ""
    firebase_client_email: str = ""
    firebase_client_id: str = ""
    firebase_auth_uri: str = "https://accounts.google.com/o/oauth2/auth"
    firebase_token_uri: str = "https://oauth2.googleapis.com/token"
    firebase_auth_provider_x509_cert_url: str = "https://www.googleapis.com/oauth2/v1/certs"
    firebase_client_x509_cert_url: str = ""

    port: int = 8000
    environment: str = "development"
    log_level: str = "INFO"
    rate_limit_per_minute: int = 10
    redis_url: str = ""
    allowed_origins: str = "http://localhost:3000,http://localhost:5173,http://localhost:8080"

    model_config = {"env_file": Path(__file__).parent / ".env", "env_file_encoding": "utf-8", "extra": "ignore"}


settings = Settings()
