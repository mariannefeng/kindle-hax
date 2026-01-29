#!/bin/sh
set -e

PORT=${PORT:-3000}
export PORT
export SCREEN_PNG_PATH=${SCREEN_PNG_PATH:-/app/screen.png}

# Generate crontab: run generate-image.sh every 3 minutes (cron has minimal env, so pass PORT/path)
echo "*/3 * * * * PORT=${PORT} SCREEN_PNG_PATH=${SCREEN_PNG_PATH} /app/scripts/generate-image.sh || true" | crontab -
cron

# Start server in background
node dist/server.js &
SERVER_PID=$!

# Wait for server to be ready
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -sf "http://localhost:${PORT}/html" > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Generate initial screen image (so /screen works before first cron run)
/app/scripts/generate-image.sh || true

# Wait on server so container stays up and receives signals
wait $SERVER_PID
