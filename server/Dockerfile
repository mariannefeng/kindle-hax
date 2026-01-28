FROM node:20-slim

WORKDIR /app

# Install wkhtmltopdf (includes wkhtmltoimage), xvfb for headless, cron, curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    wkhtmltopdf \
    xvfb \
    cron \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev for TypeScript build)
RUN npm ci

# Copy TypeScript config and source
COPY tsconfig.json ./
COPY src/ ./src/

# Build TypeScript
RUN npm run build

# Remove dev dependencies
RUN npm prune --production

# Copy entrypoint
COPY docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV SCREEN_PNG_PATH=/app/screen.png

EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]