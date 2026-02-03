#!/usr/bin/env sh

# ignore HUP since kual will exit after pressing start, and that might kill our long running script
trap '' HUP

DIR="$(dirname "$0")"
PID_FILE="${DIR}/.dash.pid"
SCREEN_URL="https://kindle.mariannefeng.com/screen"

# Sleep window: suspend at night and wake in the morning (uses RTC wakealarm + echo mem).
# Set hour in 24h form; sleep when hour >= SLEEP_AFTER or hour < SLEEP_UNTIL, wake at SLEEP_UNTIL.
SLEEP_AFTER_HOUR=22   # 10 PM: start sleeping after this hour
SLEEP_UNTIL_HOUR=7    # 7 AM: wake at this hour and resume dashboard
RTC_WAKEALARM="/sys/class/rtc/rtc0/wakealarm"

refresh_screen() {
  curl -k "$SCREEN_URL" -o "$DIR/screen.png"
  eips -c
  eips -c
  eips -g "$DIR/screen.png" -x 0 -y 30 -w gc16
  # Draw date/time and battery at top (eips can't print %, so we strip it from gasgauge-info -c)
  eips 1 1 "$(TZ=EST5EDT date '+%Y-%m-%d %I:%M %p') - wifi $(cat /sys/class/net/wlan0/operstate 2>/dev/null || echo '?') - battery: $(gasgauge-info -c 2>/dev/null | sed 's/%//g' || echo '?')"
}

# Returns true (0) if we're in the sleep window (should suspend until morning).
in_sleep_window() {
  hour=$(date +%H)
  [ "$hour" -ge "$SLEEP_AFTER_HOUR" ] || [ "$hour" -lt "$SLEEP_UNTIL_HOUR" ]
}

# Set RTC wakealarm to next occurrence of SLEEP_UNTIL_HOUR (e.g. 7 AM), then suspend.
# On wake the script resumes and the refresh loop continues.
# If your Kindle's date(1) doesn't support -d, wake_epoch falls back to now+1h and only one suspend happens.
do_night_suspend() {
  today=$(date +%Y-%m-%d)
  hh=$(printf '%02d' "$SLEEP_UNTIL_HOUR")
  today_wake=$(date -d "$today $hh:00:00" +%s 2>/dev/null)
  now=$(date +%s)
  if [ -n "$today_wake" ] && [ "$now" -ge "$today_wake" ]; then
    wake_epoch=$((today_wake + 86400))
  else
    wake_epoch=${today_wake:-$((now + 3600))}
  fi
  if [ ! -w "$RTC_WAKEALARM" ]; then
    echo "No RTC wakealarm at $RTC_WAKEALARM, skipping night suspend" >&2
    return 1
  fi
  echo 0 > "$RTC_WAKEALARM"
  echo "$wake_epoch" > "$RTC_WAKEALARM"
  sync
  echo "mem" > /sys/power/state
  return 0
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
# In the sleep window (e.g. 10 PM–7 AM), suspend until morning; otherwise refresh.
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