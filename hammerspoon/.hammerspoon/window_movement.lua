hs.window.animationDuration = 0
units = {
  right50  = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  left50   = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  top50    = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50    = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  maximum  = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  topLeft  = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
  topRight = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
  botLeft  = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
  botRight = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 },
  centre   = { x = 0.125, y = 0.125, w = 0.75, h = 0.75 }
}

mash = { 'alt', 'ctrl', 'cmd' }

hs.hotkey.bind(mash, 'c', function() hs.window.focusedWindow():move(units.centre, nil, true) end)
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, 'left', function() hs.window.focusedWindow():move(units.left50, nil, true) end)
hs.hotkey.bind(mash, 'up', function() hs.window.focusedWindow():move(units.top50, nil, true) end)
hs.hotkey.bind(mash, 'down', function() hs.window.focusedWindow():move(units.bot50, nil, true) end)
hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(units.maximum, nil, true) end)

hs.hotkey.bind(mash, '1', function() hs.window.focusedWindow():move(units.topLeft, nil, true) end)
hs.hotkey.bind(mash, '2', function() hs.window.focusedWindow():move(units.topRight, nil, true) end)
hs.hotkey.bind(mash, '3', function() hs.window.focusedWindow():move(units.botLeft, nil, true) end)
hs.hotkey.bind(mash, '4', function() hs.window.focusedWindow():move(units.botRight, nil, true) end)

hs.hotkey.bind(mash, 'f', function() hs.window.focusedWindow():toggleFullScreen() end)
hs.hotkey.bind(mash, 'z', function() hs.window.focusedWindow():toggleZoom() end)

hs.hotkey.bind(mash, "n", function()
  local currentWin = hs.window.focusedWindow()
  local nextScreen = currentWin:screen():next()
  currentWin:moveToScreen(nextScreen)
end)

hs.hotkey.bind(mash, "p", function()
  local currentWin = hs.window.focusedWindow()
  local nextScreen = currentWin:screen():previous()
  currentWin:moveToScreen(nextScreen)
end)

hs.hotkey.bind(mash, "f", function()
  local currentWin = hs.window.focusedWindow()
  currentWin:setFullScreen(not currentWin:isFullScreen())
end)
