wifiWatcher = nil

if hs.fs.attributes("~/.hammerspoon/ssid.json") then
  homeSSID = hs.json.read("~/.hammerspoon/ssid.json").home
else
  homeSSID = ""
end
lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
  local newSSID = hs.wifi.currentNetwork()

  local config = hs.network.configuration.open()
  if newSSID == homeSSID and lastSSID ~= homeSSID then
    -- We just joined our home WiFi network
    config:setLocation("Home")
  elseif newSSID ~= homeSSID and lastSSID == homeSSID then
    -- We just departed our home WiFi network
    config:setLocation("Automatic")
  end

  lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

