# Backend

Copy `.env.example` to `.env`, set secrets, install `best.pt`, then either:

docker compose up --build -d

from project root, or locally:

pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000

Main endpoints:
- POST /api/v1/auth/token
- POST /api/v1/parking/scan
- POST /api/v1/parking/manual
- GET /api/v1/parking/active
- GET /api/v1/parking/history
- GET /api/v1/parking/summary
- GET/POST /api/v1/admin/users
- GET/POST /api/v1/admin/vehicles
