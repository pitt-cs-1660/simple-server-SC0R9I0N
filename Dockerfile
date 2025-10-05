# Build Stage
FROM python:3.12 AS builder

# Install uv
RUN pip install uv
WORKDIR /app

# Copy dependency file
COPY pyproject.toml ./
COPY cc_simple_server/ cc_simple_server/

# Install dependencies into a virtual environment
RUN uv venv .venv && uv pip install -e .

# Final Stage
FROM python:3.12-slim AS final

# Create non-root user
RUN useradd -m appuser
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv /app/.venv
COPY cc_simple_server/ cc_simple_server/
COPY tests/ tests/

# Activate virtual environment
ENV PATH="/app/.venv/bin:$PATH"

RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]