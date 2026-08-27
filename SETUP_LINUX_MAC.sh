#!/usr/bin/env sh
set -eu
[ -f .env ] || cp .env.example .env
[ -f backend/.env ] || cp backend/.env.example backend/.env
echo "Environment templates created."
echo "Edit .env and backend/.env, install backend/models/best.pt, then:"
echo "docker compose up --build -d"
