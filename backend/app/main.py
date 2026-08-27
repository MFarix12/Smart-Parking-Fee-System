from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from app.core.config import get_settings
from app.core.security import hash_password
from app.db import Base, SessionLocal, engine
from app.models import User, UserRole
from app.routers import admin, auth, parking
from app.services.anpr import model_available

settings = get_settings()

def bootstrap_database():
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        email = settings.admin_email.strip().lower()
        if not db.scalar(select(User).where(User.email == email)):
            db.add(User(
                email=email, full_name="System Administrator",
                password_hash=hash_password(settings.admin_password),
                role=UserRole.ADMIN, is_active=True
            ))
            db.commit()

@asynccontextmanager
async def lifespan(app: FastAPI):
    settings.scan_storage_path.mkdir(parents=True, exist_ok=True)
    bootstrap_database()
    yield

app = FastAPI(title=settings.app_name, version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=settings.cors_origin_list != ["*"],
    allow_methods=["*"], allow_headers=["*"]
)
app.include_router(auth.router, prefix=settings.api_v1_prefix)
app.include_router(parking.router, prefix=settings.api_v1_prefix)
app.include_router(admin.router, prefix=settings.api_v1_prefix)

@app.get("/")
def root():
    return {"name": settings.app_name, "docs": "/docs", "api": settings.api_v1_prefix}

@app.get("/health")
def health():
    return {"ok": True, "environment": settings.environment, "anpr_model_installed": model_available()}
