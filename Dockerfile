FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    WITSY_HOME=/data/witsy \
    HOME=/data/home \
    NOVNC_PORT=8080 \
    VNC_PORT=5900 \
    DISPLAY=:99 \
    ELECTRON_DISABLE_SANDBOX=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dumb-init \
    fluxbox \
    git \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libexpat1 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    novnc \
    python3-websockify \
    x11vnc \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --ignore-scripts --no-audit --no-fund

COPY . .
RUN chmod +x docker/start-online.sh \
    && mkdir -p /data/witsy /data/home \
    && npx patch-package

VOLUME ["/data"]
EXPOSE 8080

CMD ["dumb-init", "./docker/start-online.sh"]
