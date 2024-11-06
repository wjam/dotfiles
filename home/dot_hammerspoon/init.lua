-- Make Hammerspoon appear in Location Services list so it can be allowed to get the current WiFi
print(hs.location.get())

require("bluetooth_sleep")
require("window_movement")
require("stay_awake")
require("home_wifi")
require("automatic_lights")
require "streamdeck"
require "meeting_interruptions"
