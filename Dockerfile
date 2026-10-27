# Pinned slim base image for reproducibility and minimal image footprint
FROM python:3.12-slim

WORKDIR /app

# Dependencies layer cached separately from application source code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application source code copied afterwards
COPY . .

# Run as non-root unprivileged user for container security
RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /data \
    && chown -R appuser:appuser /app /data

USER appuser

# Default environment configuration
ENV DATA_DIR=/data \
    APP_GREETING=Hello

EXPOSE 8000

# Container healthcheck for monitoring
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
