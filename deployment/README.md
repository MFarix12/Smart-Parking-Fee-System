# Production deployment

1. Create a DNS record:
   `parking.example.com -> your server IP`

2. Configure project root `.env`:
   - DOMAIN
   - POSTGRES_DB
   - POSTGRES_USER
   - POSTGRES_PASSWORD

3. Configure `backend/.env`:
   - SECRET_KEY
   - ADMIN_EMAIL
   - ADMIN_PASSWORD
   - tariff values
   - CORS_ORIGINS

4. Copy trained model:
   `backend/models/best.pt`

5. From `deployment/` run:
   `docker compose -f docker-compose.production.yml --env-file ../.env up --build -d`

6. Verify:
   `https://YOUR_DOMAIN/health`

7. Back up:
   - PostgreSQL volume/database
   - scan image volume if your retention policy requires it
