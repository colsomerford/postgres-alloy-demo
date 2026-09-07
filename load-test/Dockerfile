FROM python:3.12-slim

# Copy official compiled uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# Optimize uv for container layer caching
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Copy project definition and optional lockfile first
COPY pyproject.toml uv.lock* ./

# Synchronize dependencies into the virtual environment (.venv)
RUN uv sync --no-dev --no-install-project

# Copy application source script
COPY postgres-test.py .

# Add the uv virtual environment to PATH so 'python' calls .venv automatically
ENV PATH="/app/.venv/bin:$PATH"

CMD ["python", "postgres-test.py"]