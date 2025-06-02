# ==========================================================================
# CleanPro Dockerfile
# ==========================================================================
# Multi-stage build for a production-ready Flask application
# Author: Seno Paul
# ==========================================================================

# ==========================================================================
# Stage 1: Build dependencies
# ==========================================================================
FROM python:3.11-slim-bookworm AS builder

# Set working directory
WORKDIR /app

# Security: Set pip to not cache and not save package info
ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Create a virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# ==========================================================================
# Stage 2: Runtime
# ==========================================================================
FROM python:3.11-slim-bookworm AS runtime

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    APP_HOME="/app"

# Set working directory
WORKDIR $APP_HOME

# Security: Create a non-root user to run the application
RUN groupadd -r cleanpro && \
    useradd -r -g cleanpro -d $APP_HOME -s /sbin/nologin -c "CleanPro user" cleanpro && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY --chown=cleanpro:cleanpro . $APP_HOME

# Create directories for logs and static files
RUN mkdir -p $APP_HOME/logs $APP_HOME/static && \
    chown -R cleanpro:cleanpro $APP_HOME/logs $APP_HOME/static

# Set proper permissions
RUN chmod -R 755 $APP_HOME

# Change to non-root user
USER cleanpro

# Expose port
EXPOSE 5000

# Set health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Set the entrypoint to run with gunicorn
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--threads", "2", "--timeout", "60", "--log-level", "info", "--access-logfile", "-", "app:app"]

