# SecureApp — DevSecOps POC

A production-ready FastAPI application demonstrating a comprehensive DevSecOps pipeline implementation.

## Pipeline Stages

| Stage | Tool | Purpose |
|-------|------|---------|
| 🔴 Lint | Ruff, Flake8, Pylint, Mypy, Bandit, Hadolint, yamllint, Checkov, pydocstyle, isort, Black, Markdownlint | Code quality + IaC security |
| 🟡 Test | pytest + asyncio | Unit, integration, and security tests (≥80% coverage) |
| 🟠 SonarQube | SonarQube Cloud | Static analysis |
| 🔵 Build | Docker BuildKit + Syft | Multi-stage image + SBOM (SPDX & CycloneDX) |
| 🟣 Scan | Trivy | Vulnerability scanning against image + SBOM |
| 🟢 Sign | Cosign (key-based) | Image signing |
| 🚀 Deploy | ArgoCD + Kustomize | GitOps deployment to dev/staging/prod |

## What This POC Demonstrates

This POC showcases security at every stage of the software delivery lifecycle:

- **Shift-left security** with lint-stage SAST (Bandit, Checkov)
- **Automated testing** with security test cases
- **SBOM generation** in SPDX and CycloneDX formats
- **Image signing** with Cosign
- **GitOps deployment** with ArgoCD
- **External secrets** management with Vault ESO
- **Image verification** with Kyverno policies
- **Policy enforcement** at build and deploy time

## DevSecOps Pipeline Flow

```text
+=============================================================================+
|                           DEVSECOPS PIPELINE                                 ||
+=============================================================================+||
|                                                                              ||
|   +----------+    +----------+    +----------+    +----------+               ||
|   | COMMIT   | => |  BUILD   | => |  TEST    | => |  DEPLOY  |               ||
|   +----------+    +----------+    +----------+    +----------+               ||
|                                                                              ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 1: LINT (Security Scan)                                            ||
|   +-------------------------------------------------------------------------+||
|   | Code           | IaC         | Docker      | YAML                        ||
|   | -----------    | ----------- | ----------  | ------                      ||
|   | * Ruff         | * Checkov   | * Hadolint  | * yamllint                  ||
|   | * Flake8       |             |             |                             ||
|   | * Pylint       |             |             |                             ||
|   | * Mypy         |             |             |                             ||
|   | * Bandit       |             |             |                             ||
|   | * isort        |             |             |                             ||
|   |                |             |             |                             ||
|   |                |             |             |                             ||
|   +-------------------------------------------------------------------------+||
|                                                                              ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 2: TEST (Security Tests)                                           ||
|   +-------------------------------------------------------------------------+||
|   | Unit            | Integration      | Security      | Coverage            ||
|   | ------------    | -----------      | --------      | --------            ||
|   | * pytest        | * pytest         | * pytest      | * pytest-cov        ||
|   | * pytest-cov    | * requests       | * safety      | * coverage          ||
|   | * pytest-asyncio|                  | * bandit      |                     ||
|   |                 |                  |               |                     ||
|   +-------------------------------------------------------------------------+||
|                                                                              ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 3: SONARQUBE                                                       ||
|   +-------------------------------------------------------------------------+||
|   | Static Analysis | Quality Gate |                                         ||
|   | -------------   | ------------ |                                         ||
|   | * Code smells   | * Quality    |                                         ||
|   | * Bugs          |   status     |                                         ||
|   | * Vulnerabili-  |              |                                         ||
|   |   ties          |              |                                         ||
|   | * Security      |              |                                         ||
|   |   hotspots      |              |                                         ||
|   +--------------------------------------------------------------------------||+||                                                                            ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 4: BUILD (Container + SBOM)                                        ||
|   +-------------------------------------------------------------------------+||
|   | Container Build | Image Stats     | SBOM Generation                      ||
|   | -------------   | ----------      | ------------                         ||
|   | * BuildKit      | * docker        | * Syft                               ||
|   | * Multi-stage   |   history       | * CycloneDX                          ||
|   | * Docker        |                 | * SPDX-JSON                          ||
|   |                 |                 |                                      ||
|   +-------------------------------------------------------------------------+||
|                                                                              ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 5: SCAN (Vulnerability Scan)                                       ||
|   +-------------------------------------------------------------------------+||
|   | Image Scan    | Config Scan  | Secret Scan  | K8s Scan                   ||
|   | -----------   | ----------   | ----------   | --------                   ||
|   | * Trivy       | * Trivy      | * Trivy      | * Trivy                    ||
|   |               | * Checkov    |              | * Checkov                  ||
|   |               |              |              |                            ||
|   +-------------------------------------------------------------------------+||
|                                                                              ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 6: SIGN (Image Attestation)                                        ||
|   +-------------------------------------------------------------------------+||
|   | Image Signing | SBOM Attestation                                         ||
|   | ------------  | -----------------                                        ||
|   | * Cosign      | * Cosign                                                 ||
|   |               | * Attestation                                            ||
|   |               |   attach                                                 ||
|   +-------------------------------------------------------------------------+||
|                                                                              ||
|   +-------------------------------------------------------------------------+||
|   | STAGE 7: DEPLOY (GitOps)                                                 ||
|   +-------------------------------------------------------------------------+||
|   | Deployment    | Secrets      | Policy                                    ||
|   | -----------   | ----------   | ----------                                ||
|   | * ArgoCD      | * Vault      | * Kyverno                                 ||
|   | * Kustomize   |   ESO        |                                           ||
|   | * Helm        | * External   |                                           ||
|   |               |   Secrets    |                                           ||
|   +-------------------------------------------------------------------------+||
+=============================================================================+
```

## Detailed Technology Stack

- **Runtime**: Python 3.12 + FastAPI + Uvicorn
- **Database**: PostgreSQL 16 (async via SQLAlchemy + asyncpg)
- **Cache**: Redis 7
- **Auth**: JWT (HS256) + bcrypt
- **Observability**: structlog (JSON) + Prometheus metrics + OpenTelemetry
- **Container**: Multi-stage Docker image, non-root user, read-only filesystem
- **Kubernetes**: Kustomize base + dev/staging/prod overlays, HPA, NetworkPolicy, PDB, Kyverno (image policies), Vault ESO (external secrets)

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

# 5. Run database migrations
alembic upgrade head

# 6. Run the application
uvicorn src.app.main:app --reload --host 0.0.0.0 --port 8000
```

Open <http://localhost:8000/docs> for the interactive API documentation.

## Database Migrations

```bash
# Install alembic
pip install alembic

# Create a new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# View migration history
alembic history --verbose
```

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

# Documentation linting
pydocstyle src/ --convention=pep257 --add-ignore=D100,D101,D102,D103,D104,D105,D107

# Import sorting
isort --check-only --diff src/

# Code formatting
black --check src/

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

### Health & Metrics

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/health` | ❌ | Full health check |
| GET | `/api/v1/health/live` | ❌ | Kubernetes liveness probe |
| GET | `/api/v1/health/ready` | ❌ | Kubernetes readiness probe |
| GET | `/api/v1/metrics` | ❌ | Prometheus metrics |

### Authentication

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/token` | ❌ | Login (get JWT tokens) |
| POST | `/api/v1/auth/refresh` | ❌ | Refresh access token |
| GET | `/api/v1/auth/me` | ✅ | Current user profile |

### Users

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/users/` | ❌ | Register a new user |
| GET | `/api/v1/users/` | 🔑 Admin | List all users |
| GET | `/api/v1/users/{id}` | ✅ | Get user by ID |
| PATCH | `/api/v1/users/{id}` | ✅ | Update user |
| DELETE | `/api/v1/users/{id}` | 🔑 Admin | Deactivate user |

### Items

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/items/` | ✅ | List items |
| POST | `/api/v1/items/` | ✅ | Create item |
| GET | `/api/v1/items/{id}` | ✅ | Get item |
| PATCH | `/api/v1/items/{id}` | ✅ | Update item |
| DELETE | `/api/v1/items/{id}` | ✅ | Delete item |

## Project Structure

```text
.
├── .github/
│   ├── buildkitd.toml          # Docker BuildKit config
│   └── workflows/
│       ├── devsecops-pipeline.yml
│       └── opencode.yml
├── alembic/
│   ├── versions/               # Database migrations
│   ├── env.py                 # Alembic environment
│   └── script.py.mako
├── argocd/
│   └── secureapp-dev.yaml      # ArgoCD application config
├── docker/
│   └── Dockerfile              # Multi-stage production image
├── k8s/
│   ├── base/                   # Kustomize base manifests
│   ├── overlays/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── kyverno/               # Kyverno image policies
│   └── vault-eso/            # Vault External Secrets Operator
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
| `ARGOCD_SERVER` | ArgoCD server hostname |
| `ARGOCD_TOKEN` | ArgoCD authentication token |
| `COSIGN_PRIVATE_KEY` | Cosign private key (optional - keyless used by default) |
| `COSIGN_PASSWORD` | Cosign private key passphrase |
| `COSIGN_PUBLIC_KEY` | Cosign public key for verification |
| `GIT_TOKEN_COMMIT` | Git token for committing manifest changes |

## Pre-commit Hooks

### Installation

```bash
# Install pre-commit
pip install pre-commit

# Install git hooks
pre-commit install

# Run against all files
pre-commit run --all-files
```

### Available Hooks

| Hook | Purpose | Status |
|------|---------|--------|
| gitleaks | Detect secrets in code | ✅ |
| trailing-whitespace | Remove trailing whitespace | ✅ |
| detect-private-key | Catch raw PEM/RSA keys | ✅ |
| check-added-large-files | Prevent large file commits (>512KB) | ✅ |
| hadolint-docker | Lint Dockerfiles | ✅ |
| checkov | IaC security scanning | ✅ |

### Configuration

The pre-commit hooks are configured in `.pre-commit-config.yaml`. To customize:

```bash
# Validate config
pre-commit validate-config .pre-commit-config.yaml
```

## SonarQube Extension

### VS Code Integration

1. Install the [SonarQube extension](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarlint-vscode) from VS Code marketplace
2. Connect to SonarQube Cloud:
   - Press `Ctrl+Shift+P` → "SonarQube: Connect to SonarQube"
   - Enter your SonarCloud organization: `devsecops-poc`
3. Configure `sonar-project.properties` (already configured)
4. Run analysis: `SonarQube: Analyze`

### Local CLI Analysis

```bash
# Install SonarScanner
brew install sonar-scanner  # macOS
# or
sudo apt-get install sonar-scanner  # Linux

# Run analysis
sonar-scanner -Dsonar.projectKey=ahmed-magdi2712_DevSecOps-Usecase
```

### Configuration

The SonarQube configuration is in `sonar-project.properties`:

```properties
sonar.projectKey=ahmed-magdi2712_DevSecOps-Usecase
sonar.projectName=DevSecOps-Usecase
sonar.organization=devsecops-poc
sonar.python.version=3.13
sonar.python.coverage.reportPaths=reports/coverage.xml
```

## OpenCode AI Assistant

### GitHub Integration (Comment Commands)

OpenCode is integrated via `.github/workflows/opencode.yml`. Use it on GitHub:

**On PR Comment:**
```text
/oc review this code and suggest improvements

/oc fix the security vulnerability in src/app/auth.py

/oc add unit tests for the user service
```

**On Issue Comment:**
```text
/opencode how do I implement JWT authentication?

/oc explain the CI/CD pipeline flow
```

### Trigger Commands

| Command | Description |
|---------|-------------|
| `/oc` | Run OpenCode on PR/issue |
| `/opencode` | Alternative trigger |
| `@opencode` | Mention to trigger |

### Permissions Required

- `id-token: write` - For OIDC authentication
- `contents: read` - Read repository code
- `pull-requests: read` - Read PR context
- `issues: read` - Read issue context

### Local Usage

```bash
# Install OpenCode CLI
npm install -g opencode

# Run analysis
opencode --src ./src/app --describe "find security issues"

# Review specific file
opencode --file src/app/main.py --task "improve error handling"
```

### GitHub Secrets

Add `OPENCODE_API_KEY` to GitHub secrets for authentication.

## Required GitHub Variables

| Variable | Description |
|----------|-------------|
| `COSIGN_PUBLIC_KEY` | Cosign public key for image verification |

## License

MIT
