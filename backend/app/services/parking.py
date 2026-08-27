from datetime import datetime, timezone
import math
from fastapi import HTTPException
from sqlalchemy import select
from app.core.config import get_settings
from app.models import AccessStatus, Direction, ParkingSession, RegisteredVehicle, SessionStatus
from app.services.fee import calculate_fee_cents
from app.services.plate import normalize_plate

settings = get_settings()

def process_parking(db, user, direction, plate_number, image_path=None):
    plate = normalize_plate(plate_number)
    vehicle = db.scalar(select(RegisteredVehicle).where(RegisteredVehicle.plate_number == plate))
    if vehicle and vehicle.access_status == AccessStatus.BLOCKED:
        raise HTTPException(status_code=403, detail=f"{plate} is blocked.")
    if not vehicle and not settings.allow_unregistered_vehicles:
        raise HTTPException(status_code=403, detail=f"{plate} is not registered.")

    active = db.scalar(
        select(ParkingSession).where(
            ParkingSession.plate_number == plate,
            ParkingSession.status == SessionStatus.IN
        ).order_by(ParkingSession.entry_at.desc())
    )
    now = datetime.now(timezone.utc)

    if direction == Direction.ENTRY:
        if active:
            raise HTTPException(status_code=409, detail=f"{plate} is already inside.")
        item = ParkingSession(
            plate_number=plate, entry_at=now, status=SessionStatus.IN,
            entry_operator_id=user.id, entry_image_path=image_path
        )
        db.add(item); db.flush()
        return item

    if not active:
        raise HTTPException(status_code=404, detail=f"No active session for {plate}.")

    minutes = int(math.ceil(max(0,(now-active.entry_at).total_seconds())/60))
    active.exit_at = now
    active.duration_minutes = minutes
    active.fee_cents = calculate_fee_cents(minutes)
    active.status = SessionStatus.OUT
    active.exit_operator_id = user.id
    active.exit_image_path = image_path
    db.flush()
    return active
