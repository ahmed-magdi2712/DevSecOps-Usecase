# SecureApp — DevSecOps POC

A production-ready **FastAPI** application built to demonstrate every stage of the DevSecOps pipeline.

## Pipeline Stages

| Stage | Tool | Purpose |
|-------|------|---------|
| 🔴 Lint | Ruff, Flake8, Pylint, Mypy, Bandit, Hadolint, yamllint, Checkov | Code quality + IaC security |
| 🟡 Test | pytest + asyncio | Unit, integration, and security tests (≥80% coverage) |
| 🟠 SonarQube | SonarQube Cloud with AI CodeFix | Static analysis + AI suggestions |
| 🔵 Build | Docker BuildKit + Syft | Multi-stage image + SBOM (SPDX & CycloneDX) |
| 🟣 Scan | Trivy, Grype, Snyk, Anchore | Vulnerability scanning against image + SBOM |
| 🟢 Sign | Cosign (OIDC keyless + key-based) | Image signing + SLSA L3 provenance |
| 🚀 Deploy | ArgoCD + Kustomize | GitOps deployment to dev/staging/prod |

## Technology Stack

- **Runtime**: Python 3.12 + FastAPI + Uvicorn
- **Database**: PostgreSQL 16 (async via SQLAlchemy + asyncpg)
- **Cache**: Redis 7
- **Auth**: JWT (HS256) + bcrypt
- **Observability**: structlog (JSON) + Prometheus metrics + OpenTelemetry
- **Container**: Multi-stage Docker image, non-root user, read-only filesystem
- **Kubernetes**: Kustomize base + dev/staging/prod overlays, HPA, NetworkPolicy, PDB

## Quick Start (Local)

```bash
# 1. Clone and enter the project
git clone <repo-url>
cd devsecops-poc

# 2. Start dependencies
docker compose up -d postgres redis

# 3. Create Python environment
python -m venv .venv && source .venv/bin/activate
pip install -r src/app/requirements.txt

# 4. Configure environment
cp .env.example .env

# 5. Run the application
uvicorn src.app.main:app --reload --host 0.0.0.0 --port 8000
```

Open <http://localhost:8000/docs> for the interactive API documentation.

## Running Tests

```bash
# Install test dependencies
pip install pytest pytest-cov pytest-asyncio pytest-mock pytest-xdist pytest-timeout httpx

# All tests with coverage
pytest src/app/tests/ --cov=src/app --cov-report=term-missing --cov-fail-under=80

# Unit tests only
pytest src/app/tests/ -m "not integration and not security" -v

# Integration tests (requires live DB + Redis)
pytest src/app/tests/integration/ -m integration -v

# Security tests
pytest src/app/tests/security/ -m security -v
```

## Running Linters

```bash
# Fast linter + formatter
ruff check src/ && ruff format --check src/

# Type checking
mypy src/ --ignore-missing-imports

# Security linting
bandit -r src/ -ll

# Dockerfile linting
hadolint docker/Dockerfile

# YAML linting
yamllint k8s/

# IaC security scanning
checkov -d k8s/ --framework kubernetes
```

## Docker

```bash
# Build the image
docker build -f docker/Dockerfile -t secureapp:local .

# Run locally
docker run -p 8000:8000 \
  -e DATABASE_URL="postgresql://app_user:app_password@host.docker.internal:5432/app_db" \
  -e REDIS_URL="redis://host.docker.internal:6379/0" \
  -e SECRET_KEY="change-me-min-32-chars-long-string!" \
  secureapp:local
```

## API Reference

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/health` | ❌ | Full health check |
| GET | `/api/v1/health/live` | ❌ | Kubernetes liveness probe |
| GET | `/api/v1/health/ready` | ❌ | Kubernetes readiness probe |
| GET | `/api/v1/metrics` | ❌ | Prometheus metrics |
| POST | `/api/v1/auth/token` | ❌ | Login (get JWT tokens) |
| POST | `/api/v1/auth/refresh` | ❌ | Refresh access token |
| GET | `/api/v1/auth/me` | ✅ | Current user profile |
| POST | `/api/v1/users/` | ❌ | Register a new user |
| GET | `/api/v1/users/` | 🔑 Admin | List all users |
| GET | `/api/v1/users/{id}` | ✅ | Get user by ID |
| PATCH | `/api/v1/users/{id}` | ✅ | Update user |
| DELETE | `/api/v1/users/{id}` | 🔑 Admin | Deactivate user |
| GET | `/api/v1/items/` | ✅ | List items |
| POST | `/api/v1/items/` | ✅ | Create item |
| GET | `/api/v1/items/{id}` | ✅ | Get item |
| PATCH | `/api/v1/items/{id}` | ✅ | Update item |
| DELETE | `/api/v1/items/{id}` | ✅ | Delete item |

## Project Structure

```
.
├── .github/
│   ├── buildkitd.toml          # Docker BuildKit config
│   └── workflows/
│       └── devsecops-pipeline.yml
├── docker/
│   └── Dockerfile              # Multi-stage production image
├── k8s/
│   ├── base/                   # Kustomize base manifests
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── src/
│   └── app/
│       ├── api/v1/             # Route handlers
│       ├── core/               # Config, security, logging
│       ├── db/                 # SQLAlchemy engine & session
│       ├── models/             # ORM models
│       ├── schemas/            # Pydantic schemas
│       ├── services/           # Business logic + cache
│       ├── tests/              # Unit, integration, security tests
│       ├── main.py             # FastAPI application factory
│       └── requirements.txt
├── .env.example
├── .markdownlint.json
├── .snyk
├── .trivy-secret.yaml
├── .yamllint
├── docker-compose.yml
├── pyproject.toml
├── pytest.ini
└── sonar-project.properties
```

## Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `SONAR_TOKEN` | SonarQube authentication token |
| `SONAR_HOST_URL` | SonarQube server URL |
| `SNYK_TOKEN` | Snyk authentication token |
| `ANCHORE_URL` | Anchore Enterprise URL |
| `ANCHORE_USER` | Anchore username |
| `ANCHORE_PASSWORD` | Anchore password |
| `ARGOCD_SERVER` | ArgoCD server hostname |
| `ARGOCD_USERNAME` | ArgoCD username |
| `ARGOCD_PASSWORD` | ArgoCD password |
| `COSIGN_PRIVATE_KEY` | Cosign private key (optional — keyless used by default) |
| `COSIGN_PASSWORD` | Cosign private key passphrase |

## License

MIT
