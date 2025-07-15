# Base image with build tools
FROM debian:bookworm-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Set workdir
WORKDIR /app

# Install system dependencies and mise dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libpq-dev \
    zstd \
    unzip \
    ca-certificates \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install mise
ENV MISE_VERSION="v2024.6.4"
RUN curl -fsSL https://mise.run | bash

# Set up mise in shell
ENV PATH="/root/.local/share/mise/bin:$PATH"
ENV MISE_DATA_DIR="/root/.local/share/mise"
ENV MISE_SETTINGS_PATH="/root/.config/mise/settings.toml"

# Configure mise to build Python from source (avoids .zst issues)
RUN mkdir -p "$(dirname "$MISE_SETTINGS_PATH")" && \
    echo '[tools]' > "$MISE_SETTINGS_PATH" && \
    echo 'python_compile = true' >> "$MISE_SETTINGS_PATH"

# Install Python 3.12 using mise (from source)
RUN mise install python@3.12 && mise use -g python@3.12

# Confirm Python version
RUN python --version

# Copy Python dependencies
COPY wealthbridge/requirements.txt /app/requirements.txt

# Upgrade pip and install requirements
RUN python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt

# Copy the rest of the application
COPY wealthbridge/ /app/

# Optional: expose port if using Django
EXPOSE 8000

# Final command (run your app as you want, e.g. Gunicorn)
CMD ["gunicorn", "wealthbridge.wsgi:application", "--bind", "0.0.0.0:8000"]
