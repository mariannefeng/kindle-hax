### todo

- add weather information to the screen (only display 4 bus times)
- handle failure scenarios:
  - what happens if wifi goes down?
  - what happens if battery dies?
  - what happens if we can't retrieve image?
  - what happens if server errors?
- save on battery
  - can we disable/turn off the screen from 9pm -> 6am?
  - wow battery isn't too bad - ~25% while being completely on for 12 hours
- ghosting is real
  - make the entire kindle screen black before putting it to sleep

### done

- a mobile friendly UI should exist at kindle.mariannefeng.com that looks good and can be bookmarked/used easily
- fix weird scrollbar behavior for results longer than the page - no longer an issue now that we're vertical
- think a bit more about interaction between image generation (every 3 mins) w/ kindle cron reload (every minute). What's most efficient and accurate?
- kual launcher???
- display some kind of basic kindle info on the screen to be helpful?? (battery life + current time would be huge)
- how come unplugging the kindle automatically makes it so that it suddenly won't reload anymore (FUCK ME it disables the fucking wifi when unplugged??)
- make it so that the bus times can be seen vertically on the kindle
- uhhh because this is cron if I restart will I not be able to ssh onto the server again if the kindle crashes and restarts or something???? DEFINITELY CHANGE TO A SCRIPT THAT I CAN RUN MANUALLY
- an easy way to "end" the script and return the kindle to normal mode -> added stop.sh that's called when the user presses the menu button
