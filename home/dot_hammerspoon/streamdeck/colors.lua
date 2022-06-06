textColor = nil
tintColor = nil
systemBackgroundColor = nil

function randomColor()
    return {
        ['hue'] = math.random(255.0) / 255.0,
        ['saturation'] = math.random(2, 10) / 10,
        ['brightness'] = 1.0,
        ['alpha'] = 1.0
    }
end

local function updateThemeColors()
    textColor = hs.drawing.color.lists()['System']['textColor']
    tintColor = hs.drawing.color.lists()['System']['systemOrangeColor']
    systemBackgroundColor = hs.drawing.color.lists()['System']['windowBackgroundColor']
end

updateThemeColors()
