import math
from app.core.config import get_settings

settings = get_settings()

def calculate_fee_cents(duration_minutes: int) -> int:
    duration_minutes = max(0, int(duration_minutes))
    if duration_minutes <= settings.grace_minutes:
        return 0
    hours = max(1, math.ceil(duration_minutes / 60))
    fee = settings.first_hour_cents + max(0, hours - 1) * settings.next_hour_cents
    if settings.daily_cap_cents > 0:
        days = max(1, math.ceil(duration_minutes / 1440))
        fee = min(fee, settings.daily_cap_cents * days)
    return int(fee)
