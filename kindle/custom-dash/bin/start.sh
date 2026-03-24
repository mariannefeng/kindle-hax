#!/usr/bin/env sh

# ignore HUP since kual will exit after pressing start, and that might kill our long running script
trap '' HUP

DIR="$(dirname "$0")"
PID_FILE="${DIR}/.dash.pid"
SCREEN_URL="https://kindle.mariannefeng.com/screen"

refresh_screen() {
  curl -k "$SCREEN_URL" -o "$DIR/screen.png"
  eips -c
  eips -c
  eips -g "$DIR/screen.png" -x 0 -y 30 -w gc16
  # Draw date/time and battery at top (eips can't print %, so we strip it from gasgauge-info -c)
  eips 1 1 "$(date '+%Y-%m-%d %I:%M %p') - wifi $(cat /sys/class/net/wlan0/operstate 2>/dev/null || echo '?') - battery: $(gasgauge-info -c 2>/dev/null | sed 's/%//g' || echo '?')"
}

in_sleep_window() {
  hour=$(date +%H)
  # sleep if later than 8pm or before 6am
  [ "$hour" -ge 20 ] || [ "$hour" -lt 6 ]
}

# Blocks until wake time via rtcwake.
do_night_suspend() {
  sync

  # Before sleeping, kill wifi
  /sbin/stop wifis
  /sbin/stop wifim
  /sbin/stop wifid

  NOW=$(date +%s)

  YEAR=$(date +%Y)
  MONTH=$(date +%m)
  DAY=$(date +%d)
  TARGET=$(date -d "$YEAR.$MONTH.$DAY-06:00:00" +%s)

  # guarantees that the wake up time is always 6am server (ny time) in the future
  if [ "$NOW" -ge "$TARGET" ]; then
      TARGET=$(( TARGET + 86400 ))
  fi

  WAKE_IN_SECONDS=$(( TARGET - NOW ))
  rtcwake -d rtc1 -m mem -s "$WAKE_IN_SECONDS"
}

# Keep the screen on (no screensaver) while the dashboard is running
lipc-set-prop com.lab126.powerd preventScreenSaver 1

# ignore term since stopping the framework/gui will send a TERM signal to our script since kual is probably related to the GUI
trap '' TERM

# Make sure wifi is up again
/sbin/start wifid
/sbin/start wifim
/sbin/start wifis

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