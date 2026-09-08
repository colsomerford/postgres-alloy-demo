FROM python:3.12-slim

# Copy official compiled uv binary
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# Copy certificate into the system CA directory
COPY nscacert_combined.pe[m] /usr/local/share/ca-certificates/load-test/nscacert_combined.crt

# Update system CA store
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Optimize uv for container layer caching
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
# Force uv to use the native system trust store
ENV UV_NATIVE_TLS=true
# Point OpenSSL and Python tools to the system certificate bundle
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Copy project definition and optional lockfile first
COPY pyproject.toml uv.lock* ./

# Synchronize dependencies into the virtual environment (.venv)
RUN uv sync --no-dev --no-install-project --system-certs

# Copy application source script
COPY postgres-test.py .

# Add the uv virtual environment to PATH so 'python' calls .venv automatically
ENV PATH="/app/.venv/bin:$PATH"

CMD ["python", "postgres-test.py"]