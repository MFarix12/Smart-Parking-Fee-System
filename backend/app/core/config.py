from functools import lru_cache
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "Permanent ANPR Parking"
    environment: str = "production"
    api_v1_prefix: str = "/api/v1"
    secret_key: str = "CHANGE_ME"
    access_token_expire_minutes: int = 480
    admin_email: str = "admin@example.com"
    admin_password: str = "ChangeMe123!"
    database_url: str = "postgresql+psycopg://parking:parking@db:5432/parking"
    model_path: str = "/app/models/best.pt"
    scan_storage_dir: str = "/app/data/scans"
    anpr_confidence: float = 0.35
    ocr_min_confidence: float = 0.20
    max_upload_mb: int = 12
    allow_unregistered_vehicles: bool = True
    grace_minutes: int = 15
    first_hour_cents: int = 200
    next_hour_cents: int = 100
    daily_cap_cents: int = 2000
    cors_origins: str = "*"

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8",
        case_sensitive=False, extra="ignore"
    )

    @property
    def cors_origin_list(self):
        raw = self.cors_origins.strip()
        return ["*"] if raw == "*" else [x.strip() for x in raw.split(",") if x.strip()]

    @property
    def scan_storage_path(self):
        return Path(self.scan_storage_dir)

@lru_cache
def get_settings():
    return Settings()
