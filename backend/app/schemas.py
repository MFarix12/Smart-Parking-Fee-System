from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from app.models import AccessStatus, Direction, SessionStatus, UserRole

class UserRead(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    role: UserRole
    is_active: bool
    model_config = {"from_attributes": True}

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead

class UserCreate(BaseModel):
    email: EmailStr
    full_name: str = Field(min_length=2, max_length=255)
    password: str = Field(min_length=8, max_length=128)
    role: UserRole = UserRole.OPERATOR

class VehicleCreate(BaseModel):
    plate_number: str
    owner_name: str | None = None
    vehicle_type: str | None = None
    access_status: AccessStatus = AccessStatus.ACTIVE
    notes: str | None = None

class VehicleRead(BaseModel):
    id: str
    plate_number: str
    owner_name: str | None
    vehicle_type: str | None
    access_status: AccessStatus
    notes: str | None
    created_at: datetime
    model_config = {"from_attributes": True}

class ManualParkingRequest(BaseModel):
    direction: Direction
    plate_number: str

class ParkingSessionRead(BaseModel):
    id: str
    plate_number: str
    entry_at: datetime
    exit_at: datetime | None
    duration_minutes: int | None
    fee_cents: int | None
    status: SessionStatus
    entry_image_path: str | None
    exit_image_path: str | None
    model_config = {"from_attributes": True}

class ScanResponse(BaseModel):
    success: bool
    direction: Direction
    plate_number: str
    detection_confidence: float | None = None
    ocr_confidence: float | None = None
    gate_action: str
    message: str
    session: ParkingSessionRead

class ParkingSummary(BaseModel):
    active_vehicles: int
    today_entries: int
    today_exits: int
    today_revenue_cents: int
