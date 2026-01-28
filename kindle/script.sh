# todo: setup cron, disable screensaver, disable top nav bar

# download the screen image
curl -k https://kindle.mariannefeng.com/screen -o screen.png
# clear the screen twice
eips -c
eips -c

# display the screen image
eips -g screen.png -f