from datetime import datetime, timezone
from pathlib import Path
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy import func, select
from sqlalchemy.orm import Session
from app.core.config import get_settings
from app.db import get_db
from app.deps import get_current_user
from app.models import Direction, ParkingSession, ScanEvent, SessionStatus, User
from app.schemas import ManualParkingRequest, ParkingSessionRead, ParkingSummary, ScanResponse
from app.services.anpr import recognize_plate
from app.services.parking import process_parking
from app.services.plate import normalize_plate
from app.services.storage import save_scan_image

router = APIRouter(prefix="/parking", tags=["Parking"])
settings = get_settings()

def build_response(direction, recognition, session):
    if direction == Direction.ENTRY:
        msg = f"{session.plate_number} entered successfully."
    else:
        msg = f"{session.plate_number} exited. Fee RM {(session.fee_cents or 0)/100:.2f}"
    return ScanResponse(
        success=True, direction=direction, plate_number=session.plate_number,
        detection_confidence=recognition.get("detection_confidence"),
        ocr_confidence=recognition.get("ocr_confidence"),
        gate_action="OPEN", message=msg,
        session=ParkingSessionRead.model_validate(session)
    )

@router.post("/scan", response_model=ScanResponse)
async def scan(
    direction: Direction = Form(...),
    file: UploadFile = File(...),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if file.content_type and not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Upload must be an image.")
    raw = await file.read()
    if not raw:
        raise HTTPException(status_code=400, detail="Empty image.")
    if len(raw) > settings.max_upload_mb * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Image is too large.")

    image_path = save_scan_image(raw, Path(file.filename or "").suffix or ".jpg")
    event = ScanEvent(direction=direction, operator_id=user.id, image_path=image_path, accepted=False)
    db.add(event)
    recognition = {}
    try:
        recognition = recognize_plate(raw)
        session = process_parking(
            db, user, direction, recognition["plate_number"], image_path
        )
        event.plate_number = recognition["plate_number"]
        event.detection_confidence = int(round(recognition["detection_confidence"] * 10000))
        event.ocr_confidence = int(round(recognition["ocr_confidence"] * 10000))
        event.accepted = True
        event.reason = "OK"
        db.commit(); db.refresh(session)
        return build_response(direction, recognition, session)
    except HTTPException as exc:
        event.plate_number = recognition.get("plate_number")
        event.reason = str(exc.detail)[:255]
        db.commit()
        raise

@router.post("/manual", response_model=ScanResponse)
def manual(
    payload: ManualParkingRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    plate = normalize_plate(payload.plate_number)
    if not plate:
        raise HTTPException(status_code=400, detail="Invalid plate.")
    session = process_parking(db, user, payload.direction, plate, None)
    db.add(ScanEvent(
        direction=payload.direction, plate_number=plate,
        accepted=True, reason="MANUAL_OPERATOR_ENTRY",
        operator_id=user.id
    ))
    db.commit(); db.refresh(session)
    return build_response(payload.direction, {}, session)

@router.get("/active", response_model=list[ParkingSessionRead])
def active(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return list(db.scalars(
        select(ParkingSession)
        .where(ParkingSession.status == SessionStatus.IN)
        .order_by(ParkingSession.entry_at.desc())
    ).all())

@router.get("/history", response_model=list[ParkingSessionRead])
def history(limit: int = 100, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    limit = max(1, min(limit, 500))
    return list(db.scalars(
        select(ParkingSession).order_by(ParkingSession.entry_at.desc()).limit(limit)
    ).all())

@router.get("/summary", response_model=ParkingSummary)
def summary(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    active_count = db.scalar(
        select(func.count()).select_from(ParkingSession)
        .where(ParkingSession.status == SessionStatus.IN)
    ) or 0
    entries = db.scalar(
        select(func.count()).select_from(ParkingSession)
        .where(ParkingSession.entry_at >= start)
    ) or 0
    exits = db.scalar(
        select(func.count()).select_from(ParkingSession)
        .where(ParkingSession.exit_at >= start)
    ) or 0
    revenue = db.scalar(
        select(func.coalesce(func.sum(ParkingSession.fee_cents),0))
        .where(ParkingSession.exit_at >= start)
    ) or 0
    return ParkingSummary(
        active_vehicles=int(active_count),
        today_entries=int(entries),
        today_exits=int(exits),
        today_revenue_cents=int(revenue)
    )
