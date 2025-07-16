# Base image (use stable version; Python 3.13 may not be available yet)
FROM python:3.12-slim

# Force mise (if ever used) to compile Python instead of using broken binaries
ENV MISE_SETTINGS__PYTHON_COMPILE=1

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY wealthbridge/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project files
COPY wealthbridge/ /app/

# Collect static files and prepare DB (safe even if admin creation is optional)
RUN python manage.py collectstatic --no-input && \
    python manage.py makemigrations && \
    python manage.py migrate

# Optional: Only run if you actually have this command
RUN python manage.py create_admin || echo "Admin user creation skipped."

# Expose application port
EXPOSE 8000

# Run Gunicorn
CMD ["gunicorn", "wealthbridge.wsgi:application", "--bind", "0.0.0.0:8000"]
