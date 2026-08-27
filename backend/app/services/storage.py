from datetime import datetime, timezone
import uuid
from app.core.config import get_settings

settings = get_settings()

def save_scan_image(raw: bytes, extension: str = ".jpg") -> str:
    now = datetime.now(timezone.utc)
    folder = settings.scan_storage_path / f"{now:%Y}" / f"{now:%m}" / f"{now:%d}"
    folder.mkdir(parents=True, exist_ok=True)
    ext = extension.lower()
    if ext not in {".jpg", ".jpeg", ".png", ".webp"}:
        ext = ".jpg"
    path = folder / f"{now:%H%M%S}_{uuid.uuid4().hex}{ext}"
    path.write_bytes(raw)
    return str(path)
