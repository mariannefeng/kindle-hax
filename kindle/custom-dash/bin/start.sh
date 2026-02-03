#!/usr/bin/env sh

# ignore HUP since kual will exit after pressing start, and that might kill our long running script
trap '' HUP

DIR="$(dirname "$0")"
PID_FILE="${DIR}/.dash.pid"
SCREEN_URL="https://kindle.mariannefeng.com/screen"

WAKE_IN_SECONDS=36000 # 10 hours in seconds

refresh_screen() {
  curl -k "$SCREEN_URL" -o "$DIR/screen.png"
  eips -c
  eips -c
  eips -g "$DIR/screen.png" -x 0 -y 30 -w gc16
  # Draw date/time and battery at top (eips can't print %, so we strip it from gasgauge-info -c)
  eips 1 1 "$(TZ=EST5EDT date '+%Y-%m-%d %I:%M %p') - wifi $(cat /sys/class/net/wlan0/operstate 2>/dev/null || echo '?') - battery: $(gasgauge-info -c 2>/dev/null | sed 's/%//g' || echo '?')"
}

in_sleep_window() {
  hour=$(TZ=EST5EDT date +%H)
  # sleep if later than 9pm or before 7am
  [ "$hour" -ge 21 ] || [ "$hour" -lt 7 ]
}

# Blocks until wake time via rtcwake.
do_night_suspend() {
  sync
  rtcwake -d rtc1 -m mem -s "$WAKE_IN_SECONDS"
}

# Keep the screen on (no screensaver) while the dashboard is running
lipc-set-prop com.lab126.powerd preventScreenSaver 1

# ignore term since stopping the framework/gui will send a TERM signal to our script since kual is probably related to the GUI
trap '' TERM
# Stop the Kindle UI so only our image + date/battery are visible (cleaner full-screen dashboard).
/sbin/stop framework
/sbin/stop lab126_gui

sleep 2
trap - TERM

# Refresh loop in background: fetch and display every 60 seconds.
# If in the sleep window (e.g. 9 PM–7 AM), suspend for 10 hours; otherwise refresh.
(
  while true; do
    if in_sleep_window; then
      do_night_suspend || true
    else
      refresh_screen
    fi
    sleep 60
  done
) &
echo $! > "$PID_FILE"

script -q -c "evtest /dev/input/event2 2>&1" /dev/null | grep -m 1 -q "code 102 (Home), value 1" && "$DIR/stop.sh"
exit 0