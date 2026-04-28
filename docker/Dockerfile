# syntax=docker/dockerfile:1.6
# ============================================================================
# Stage 1 – Dependencies (cached layer)
# ============================================================================
FROM python:3.12-slim AS deps

# Build-time labels
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

WORKDIR /deps

# Install build tools needed for native extensions, then clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY src/app/requirements.txt .

# Install to a prefix so we can copy only the site-packages in the next stage
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt

# ============================================================================
# Stage 2 – Runtime image (minimal attack surface)
# ============================================================================
FROM python:3.12-slim AS runtime

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.title="SecureApp" \
      org.opencontainers.image.description="DevSecOps demo FastAPI application" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}" \
      org.opencontainers.image.licenses="MIT"

# Runtime dependencies only (libpq for asyncpg)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq5 \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create a non-root user
RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid appgroup --shell /bin/bash \
       --no-create-home appuser

WORKDIR /app

# Copy installed packages from the deps stage
COPY --from=deps /install /usr/local

# Copy application source
COPY src/app/ ./src/app/

# Set correct ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 8000

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PORT=8000

# Health check used by Docker and Kubernetes
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health/live || exit 1

# Run with Uvicorn; adjust workers via WORKERS env var
CMD ["sh", "-c", "uvicorn src.app.main:app \
      --host 0.0.0.0 \
      --port ${PORT} \
      --workers ${WORKERS:-2} \
      --log-level ${LOG_LEVEL:-info} \
      --proxy-headers \
      --forwarded-allow-ips='*'"]
