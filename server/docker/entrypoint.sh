#!/bin/sh
set -e

PORT=${PORT:-3000}

# Generate crontab with current PORT, load it
# Rotate image 90 degrees clockwise after generation
echo "*/3 * * * * wkhtmltoimage --disable-javascript --no-images --quality 85 --width 600 --height 800 http://localhost:${PORT}/html /app/screen.png 2>/dev/null && convert /app/screen.png -rotate 90 /app/screen.png 2>/dev/null || true" | crontab -
cron

# Start server in background
node dist/server.js &
SERVER_PID=$!

# Wait for server to be ready
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -sf http://localhost:${PORT}/html > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Generate initial screen image (so /screen works before first cron run)
# Rotate image 90 degrees clockwise after generation
wkhtmltoimage --disable-javascript --no-images --quality 85 --width 600 --height 800 http://localhost:${PORT}/html /app/screen.png 2>/dev/null && convert /app/screen.png -rotate 90 /app/screen.png 2>/dev/null || true

# Wait on server so container stays up and receives signals
wait $SERVER_PID
