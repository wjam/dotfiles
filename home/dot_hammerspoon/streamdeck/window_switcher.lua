require "streamdeck.button_images"

function windowSwitcher(name, bundle)
  return {
    ['name'] = name,
    ['imageProvider'] = function()
      local icon = hs.image.imageFromAppBundle(bundle)
      local elements = {}
      table.insert(elements, { -- TODO be smarter about creating the image - add some background on click? (nonceButton)
          type = "image",
          image = icon,
          imageScaling = "scaleToFit"
      })
      return streamdeck_imageWithCanvasContents(elements)
    end,
    ['onClick'] = function()
      hs.application.open(bundle)
    end
  }
end

firefox = windowSwitcher('Firefox', "org.mozilla.firefox")
zoom = windowSwitcher('Zoom', "us.zoom.xos")
obs = windowSwitcher('OBS', "com.obsproject.obs-studio")
