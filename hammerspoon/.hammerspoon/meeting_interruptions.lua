-- if meeting and muted, update stream deck?

local isFocused = false

function zoom_window(element, event, watcher)
  local windowTitle = ""
  if element['title'] ~= nil then
    windowTitle = element:title()
  end

  if event == hs.uielement.watcher.elementDestroyed then
    local app = hs.application.get("us.zoom.xos")
    if (app == nil or app:findMenuItem({"Meeting", "Invite"}) == nil) and isFocused then
      hs.shortcuts.run("unfocus-mode")
      isFocused = false
    end
  end

  if event == hs.uielement.watcher.titleChanged and windowTitle == "Zoom Meeting" then
    isFocused = true
    hs.shortcuts.run("focus-mode")
  end
end

function zoom_launched(name, event, app)
  if name ~= "zoom.us" then
    return
  end

  if (name ~= "zoom.us" or event ~= hs.application.watcher.launched) then
    return
  end

  app:newWatcher(zoom_window):start({hs.uielement.watcher.windowCreated, hs.uielement.watcher.titleChanged, hs.uielement.watcher.elementDestroyed})

end

hs.application.watcher.new(zoom_launched):start()
