from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # FastAPI JWT
    secret_key: str = "change-me-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080   # 7 days
    refresh_token_expire_days: int = 30

    # Cron job secret — shared between Supabase pg_cron and this API
    cron_secret: str = "change-me-in-production"

    # Supabase — service role only, never returned to Flutter
    supabase_url: str
    supabase_service_role_key: str = ""   # canonical name per spec
    # Legacy alias used by older prototype code — mapped below
    supabase_service_key: str = ""

    # Anthropic
    anthropic_api_key: str = ""

    # Firebase — full JSON credentials string
    firebase_credentials_json: str = ""

    # App
    app_env: str = "development"
    allowed_origins: str = "*"
    heroku_app_url: str = ""

    def get_supabase_service_key(self) -> str:
        """Return whichever service key env var is set."""
        return self.supabase_service_role_key or self.supabase_service_key


settings = Settings()
