# Permanent ANPR Parking System

Production-oriented starter for a real parking operation.

## Architecture

Mobile camera → Flutter operator app → HTTPS API → YOLO plate detector →
EasyOCR → parking rules → PostgreSQL → entry/exit/history.

Google Colab is used only to train and validate the custom plate detector.
The permanent API and database run continuously on your own PC/server/VPS.

## Included

- FastAPI backend
- PostgreSQL
- JWT authentication
- Admin/operator roles
- ANPR scan API
- Malaysian-style plate normalization
- Entry/exit sessions
- Duplicate-entry protection
- Fee calculation
- Registered vehicle access rules
- Active vehicles/history/summary
- Persistent scan images
- Flutter mobile app
- Docker deployment
- Caddy HTTPS reverse proxy example
- Google Colab training notebook

## Required model

Train your detector and copy:

backend/models/best.pt

The API can start without it, but ANPR scans return 503 until it is installed.

## Quick start

1. Copy `backend/.env.example` to `backend/.env`.
2. Change SECRET_KEY, ADMIN_EMAIL and ADMIN_PASSWORD.
3. Copy `.env.example` to `.env` at project root and change DB password.
4. Put `best.pt` in `backend/models/`.
5. Run `docker compose up --build -d`.
6. Open `http://localhost:8000/docs`.

## Before a real rollout

Decide/validate your actual tariff, privacy/PDPA notices, retention,
backups, HTTPS domain, payment gateway, barrier hardware protocol,
camera placement/night performance, dataset licensing, and model licensing.
