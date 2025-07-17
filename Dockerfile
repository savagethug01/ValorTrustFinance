# Base image (use stable version; Python 3.13 may not be available yet)
FROM python:3.12-slim
FROM python:${PYTHON_VERSION}

# Ensure mise compiles Python rather than using broken prebuilt versions
ARG MISE_SETTINGS_PYTHON_COMPILE=1
ENV MISE_SETTINGS_PYTHON_COMPILE=${MISE_SETTINGS_PYTHON_COMPILE}

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

# Copy release script and make it executable
COPY release.sh /wealthbridge/release.sh
RUN chmod +x /wealthbridge/release.sh

# Expose application port
EXPOSE 8000

# Run Gunicorn
CMD ["gunicorn", "wealthbridge.wsgi:application", "--bind", "0.0.0.0:8000"]
