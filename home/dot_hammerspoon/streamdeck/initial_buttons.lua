require "streamdeck.lock"
require "streamdeck.meeting_video"
require "streamdeck.microphone"
require "streamdeck.nonce"
require "streamdeck.speakers"
require "streamdeck.window_switcher"

initialButtonState = {
    ['name'] = 'Root',
    ['buttons'] = {
        lockButton,
        firefox,
        zoom,
        nonceButton(),
        nonceButton(),
        muteMicrophone,
        startVideo,
        nonceButton(), -- leave call
        nonceButton(), -- toggle lights
        nonceButton(), -- add an hour to don't disturb?
        volumeMute,
        volumeDown,
        volumeUp,
        nonceButton(),
        nonceButton(),
    }
}
