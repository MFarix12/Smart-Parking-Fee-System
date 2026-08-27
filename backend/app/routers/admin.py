from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.core.security import hash_password
from app.db import get_db
from app.deps import require_admin
from app.models import RegisteredVehicle, User
from app.schemas import UserCreate, UserRead, VehicleCreate, VehicleRead
from app.services.plate import normalize_plate

router = APIRouter(prefix="/admin", tags=["Administration"])

@router.get("/users", response_model=list[UserRead])
def list_users(_: User = Depends(require_admin), db: Session = Depends(get_db)):
    return list(db.scalars(select(User).order_by(User.created_at.desc())).all())

@router.post("/users", response_model=UserRead, status_code=201)
def create_user(payload: UserCreate, _: User = Depends(require_admin), db: Session = Depends(get_db)):
    email = payload.email.lower()
    if db.scalar(select(User).where(User.email == email)):
        raise HTTPException(status_code=409, detail="Email already exists.")
    user = User(
        email=email, full_name=payload.full_name,
        password_hash=hash_password(payload.password),
        role=payload.role, is_active=True
    )
    db.add(user); db.commit(); db.refresh(user)
    return user

@router.get("/vehicles", response_model=list[VehicleRead])
def list_vehicles(_: User = Depends(require_admin), db: Session = Depends(get_db)):
    return list(db.scalars(select(RegisteredVehicle).order_by(RegisteredVehicle.created_at.desc())).all())

@router.post("/vehicles", response_model=VehicleRead, status_code=201)
def create_vehicle(payload: VehicleCreate, _: User = Depends(require_admin), db: Session = Depends(get_db)):
    plate = normalize_plate(payload.plate_number)
    if not plate:
        raise HTTPException(status_code=400, detail="Invalid plate.")
    if db.scalar(select(RegisteredVehicle).where(RegisteredVehicle.plate_number == plate)):
        raise HTTPException(status_code=409, detail="Plate already registered.")
    vehicle = RegisteredVehicle(
        plate_number=plate, owner_name=payload.owner_name,
        vehicle_type=payload.vehicle_type, access_status=payload.access_status,
        notes=payload.notes
    )
    db.add(vehicle); db.commit(); db.refresh(vehicle)
    return vehicle
