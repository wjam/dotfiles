if hs.fs.attributes("~/.hammerspoon/ssid.json") then
  homeSSID = hs.json.read("~/.hammerspoon/ssid.json").home
else
  homeSSID = ""
end

function cameraPropertyCallback(camera, property)
  print(camera:name())
  local ssid = hs.wifi.currentNetwork()
  if ssid == homeSSID then
    if property == "gone" then
      local status = 0
      if camera:isInUse() then
        status = 1
      end
      local numb = 1

      -- example - https://github.com/ecerulm/dotfiles/blob/bba42e7674832d03f66fecf12ce8658f89a294ef/.hammerspoon/init.lua#L138-L170
      --   curl --silent --fail --header "Content-Type: application/json" --request PUT --data-binary @- --output /dev/null $endpoint
      local data = hs.json.encode({numberOfLights=1, lights = {{on = status}}})
      local headers = {
        ["Content-Type"] = "application/json"
      }
      local code, body, headers = hs.http.put("http://elgato:9123/elgato/lights", data, headers)
      print(code)
      print(body)
      if (code > 299) then
        hs.notify.show("Lights failed", tostring(code), "Couldn't switch the lights")
      end
    end
  end
end

-- Add the property callback to all cameras that get added
function cameraWatcherCallback(camera, status)
  print(camera:name())
  print(status)
  if status == "Added" then
    camera:setPropertyWatcherCallback(cameraPropertyCallback)
    camera:startPropertyWatcher()
  end
end
hs.camera.setWatcherCallback(cameraWatcherCallback)
hs.camera.startWatcher()

-- Add the property watcher to all existing cameras
for index, camera in ipairs(hs.camera.allCameras()) do
    camera:setPropertyWatcherCallback(cameraPropertyCallback)
    camera:startPropertyWatcher()
end
