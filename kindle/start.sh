#!/usr/bin/env sh
DIR="$(dirname "$0")"
PID_FILE="${DIR}/.dash.pid"
SCREEN_URL="https://kindle.mariannefeng.com/screen"

refresh_screen() {
  curl -k "$SCREEN_URL" -o "$DIR/screen.png"
  eips -c
  eips -c
  eips -g "$DIR/screen.png"
  # Draw date/time and battery at top (eips can't print %, so we strip it from gasgauge-info -c). Date may be UTC on busybox.
  eips 1 1 "$(date '+%Y-%m-%d %H:%M')  batt $(gasgauge-info -c 2>/dev/null | sed 's/%//g' || echo '?')"
}

# Keep the screen on (no screensaver) while the dashboard is running
lipc-set-prop com.lab126.powerd preventScreenSaver 1

# Stop the Kindle UI so only our image + date/battery are visible (cleaner full-screen dashboard).
stop framework   2>/dev/null || true
stop lab126_gui  2>/dev/null || true

# Refresh loop in background: fetch and display every 60 seconds
(
  while true; do
    refresh_screen
    sleep 60
  done
) &
echo $! > "$PID_FILE"

script -q -c "evtest /dev/input/event2 2>&1" /dev/null | grep -m 1 -q "code 102 (Home), value 1" && "$DIR/stop.sh"
exit 0
