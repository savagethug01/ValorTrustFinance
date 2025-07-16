# Base image
ARG PYTHON_VERSION=3.13-slim
FROM python:${PYTHON_VERSION}

# Ensure mise compiles Python rather than using broken prebuilt versions
ARG MISE_SETTINGS_PYTHON_COMPILE=1
ENV MISE_SETTINGS_PYTHON_COMPILE=${MISE_SETTINGS_PYTHON_COMPILE}

# Environment setup
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY wealthbridge/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the full Django project
COPY wealthbridge/ /app/

# Run Django setup commands
RUN python manage.py collectstatic --no-input
RUN python manage.py makemigrations
RUN python manage.py migrate
RUN python manage.py create_admin

# Expose port
EXPOSE 8000

# Start server
CMD ["gunicorn", "wealthbridge.wsgi:application", "--bind", "0.0.0.0:8000"]
