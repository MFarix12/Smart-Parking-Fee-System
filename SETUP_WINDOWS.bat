@echo off
if not exist .env copy .env.example .env
if not exist backend\.env copy backend\.env.example backend\.env
echo.
echo Environment templates created.
echo 1. Edit .env and backend\.env and change all passwords/secrets.
echo 2. Put best.pt in backend\models\
echo 3. Run: docker compose up --build -d
echo 4. Open: http://localhost:8000/docs
pause
