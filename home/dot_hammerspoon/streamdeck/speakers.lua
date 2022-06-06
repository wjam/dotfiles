require "streamdeck.button_images"

volumeMute = {
  ['name'] = 'Volume mute',
  ['imageProvider'] = function()
    -- TODO
    -- 1. If zoom is running, check what the muted status of _that_ output speaker
    -- 2. else check default output
    return streamdeck_imageFromText('?')
  end,
  ['updateInterval'] = 1,
  ['onClick'] = function()
    -- TODO:
    -- 1. If zoom is running, mute/unmute _that_ output speaker
    -- 2. else mute/unmute default output speaker
  end,
}

volumeUp = {
  ['name'] = 'Volume up',
  ['imageProvider'] = function()
    return streamdeck_imageFromText('🔊') -- TODO icon could be a canvas with ⬆ and 🔊?
  end,
  ['onClick'] = function()
    -- TODO:
    -- 1. If zoom is running, increase the volume of _that_ output speaker
    -- 2. else increase the volume of that default output speaker
  end,
}

volumeDown = {
  ['name'] = 'Volume down',
  ['imageProvider'] = function()
    return streamdeck_imageFromText('🔉') -- TODO icon could be a canvas with ⬇ and 🔊?
  end,
  ['onClick'] = function()
    -- TODO:
    -- 1. If zoom is running, decrease the volume of _that_ output speaker
    -- 2. else decrease the volume of that default output speaker
  end,
}
