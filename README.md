# CENG413 HW-2: Multi-Service Architecture with Docker Compose

A stateless Flask web application coupled with a Redis cache service managed via Docker Compose. The services communicate seamlessly by name over Docker's internal DNS network, with state persisted externally in a named volume.

## Quick start

```bash
docker compose up -d --build
docker compose ps
curl http://localhost:8000/visit
docker compose down
```

> **Windows PowerShell Note:** On Windows PowerShell, use `curl.exe http://localhost:8000/visit` instead of `curl`.

---

## API Endpoints

| Endpoint | Method | Description | Example Response |
|---|---|---|---|
| `/health` | GET | Healthcheck endpoint | `{"status": "ok"}` |
| `/greet?name=Ada` | GET | Configurable greeting | `{"message": "Hello, Ada!"}` |
| `/visit` | GET | Stateful counter stored in Redis | `{"storage": "redis", "visits": 1}` |
| `/whoami` | GET | Returns container hostname | `{"hostname": "4f08960fa0f5"}` |

---

## Verification & Statelessness Proof

### 1. Verification of Service Health & Discovery
Run:
```bash
docker compose ps
```
Both `app` and `cache` services will be `Up`, with `cache` marked as `(healthy)`. The `app` service only starts after `cache` passes its healthcheck.

### 2. Proving App Statelessness
To verify that the application container keeps zero state locally:
```bash
# Call the counter
curl http://localhost:8000/visit
curl http://localhost:8000/visit

# Remove only the app container and recreate it
docker compose rm -sf app
docker compose up -d app

# Verify the counter continues without resetting
curl http://localhost:8000/visit
```
The counter continues its sequence because all state resides in Redis.

### 3. Data Persistence Across Restarts vs. Volume Reset
```bash
# Stop and remove containers (volume stays intact)
docker compose down
docker compose up -d
curl http://localhost:8000/visit   # Counter preserves previous value

# Remove containers AND delete the named volume
docker compose down -v
docker compose up -d
curl http://localhost:8000/visit   # Counter resets back to 1
```

---

## Running Unit Tests

To run the unit test suite locally without needing a live Redis server:
```bash
pip install -r requirements.txt pytest
pytest
```
