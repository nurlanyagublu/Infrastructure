FROM python:3.10-slim-bookworm

# Create non-root user for security (ECS best practice)
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    postgresql-client \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Python package managers
RUN pip install -U pip \
    && pip install --no-cache poetry

# Set up working directory
WORKDIR /app

# Copy dependency files first (for better Docker layer caching)
COPY pyproject.toml poetry.lock ./

# Configure poetry and install dependencies (production only)
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user (ECS security requirement)
USER appuser

# ECS Fargate health check (ALB will also do health checks)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

# Expose port 8080 (ALB target group port)
EXPOSE 8080

# Environment variables for ECS Fargate
ENV FLASK_APP=realworld.app
ENV FLASK_ENV=development
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8080
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Use startup script for database initialization
CMD ["./scripts/start.sh"]
