#!/bin/sh
set -e

PORT=${PORT:-3000}
OUTPUT="${SCREEN_PNG_PATH:-/app/screen.png}"
URL="http://localhost:${PORT}/html"

wkhtmltoimage --disable-javascript --no-images --quality 85 --width 600 --height 800 "$URL" "$OUTPUT" 2>/dev/null && convert "$OUTPUT" -rotate -90 "$OUTPUT" 2>/dev/null
