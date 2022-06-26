require "streamdeck.button_images"

startVideo = {
  ['name'] = 'Start Video',
  ['imageProvider'] = function()
    local app = hs.application.get("us.zoom.xos")
    local icon = "📸"
    if app == nil or app:findMenuItem({"Meeting", "Keep on Top"}) == nil or app:findMenuItem({"Meeting", "Start Video"}) ~= nil then
      icon = "📷"
    end
    return streamdeck_imageFromText(icon)
  end,
  ['updateInterval'] = 1,
  ['onClick'] = function()
    local app = hs.application.get("us.zoom.xos")
    if app == nil then return end
    if app:findMenuItem({"Meeting", "Start Video"}) == nil then
      app:selectMenuItem({"Meeting", "Stop Video"})
    else
      app:selectMenuItem({"Meeting", "Start Video"})
    end
  end
}
