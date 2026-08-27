import enum, uuid
from datetime import datetime, timezone
from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column
from app.db import Base

def utcnow():
    return datetime.now(timezone.utc)

class UserRole(str, enum.Enum):
    ADMIN = "ADMIN"
    OPERATOR = "OPERATOR"

class SessionStatus(str, enum.Enum):
    IN = "IN"
    OUT = "OUT"

class Direction(str, enum.Enum):
    ENTRY = "ENTRY"
    EXIT = "EXIT"

class AccessStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    BLOCKED = "BLOCKED"

class User(Base):
    __tablename__ = "users"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    full_name: Mapped[str] = mapped_column(String(255))
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.OPERATOR)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

class RegisteredVehicle(Base):
    __tablename__ = "registered_vehicles"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    plate_number: Mapped[str] = mapped_column(String(20), unique=True, index=True)
    owner_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    vehicle_type: Mapped[str | None] = mapped_column(String(80), nullable=True)
    access_status: Mapped[AccessStatus] = mapped_column(Enum(AccessStatus), default=AccessStatus.ACTIVE)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

class ParkingSession(Base):
    __tablename__ = "parking_sessions"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    plate_number: Mapped[str] = mapped_column(String(20), index=True)
    entry_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)
    exit_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    duration_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    fee_cents: Mapped[int | None] = mapped_column(Integer, nullable=True)
    status: Mapped[SessionStatus] = mapped_column(Enum(SessionStatus), default=SessionStatus.IN, index=True)
    entry_operator_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    exit_operator_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    entry_image_path: Mapped[str | None] = mapped_column(String(500), nullable=True)
    exit_image_path: Mapped[str | None] = mapped_column(String(500), nullable=True)

class ScanEvent(Base):
    __tablename__ = "scan_events"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    direction: Mapped[Direction] = mapped_column(Enum(Direction))
    plate_number: Mapped[str | None] = mapped_column(String(20), nullable=True, index=True)
    detection_confidence: Mapped[int | None] = mapped_column(Integer, nullable=True)
    ocr_confidence: Mapped[int | None] = mapped_column(Integer, nullable=True)
    accepted: Mapped[bool] = mapped_column(Boolean, default=False)
    reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    image_path: Mapped[str | None] = mapped_column(String(500), nullable=True)
    operator_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, index=True)
