require "streamdeck.button_images"

muteMicrophone = {
  ['name'] = 'Mute Microphone',
  ['imageProvider'] = function()
    local app = hs.application.get("us.zoom.xos")
    local icon = "🔈" -- TODO change to use 🎤
    -- TODO this doesn't seem to work properly when Zoom is open but no meeting started?
    if app == nil or app:findMenuItem({"Meeting", "Keep on Top"}) == nil or app:findMenuItem({"Meeting", "Unmute Audio"}) ~= nil then
      icon = "🔇"
    end
    return streamdeck_imageFromText(icon)
  end,
  ['updateInterval'] = 1,
  ['onClick'] = function()
    local app = hs.application.get("us.zoom.xos")
    if app == nil then return end
    if app:findMenuItem({"Meeting", "Mute Audio"}) == nil then
      app:selectMenuItem({"Meeting", "Unmute Audio"})
    else
      app:selectMenuItem({"Meeting", "Mute Audio"})
    end
  end,
}
