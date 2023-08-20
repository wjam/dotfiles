local wezterm = require 'wezterm'
local helpers = require 'helpers'

local powerlineGoAppearanceFile = wezterm.home_dir .. "/.config/powerline-go/appearance.txt"

function scheme_for_appearance()
  -- The multiplexer may not be connected to a GUI, so attempting to resolve this module from the mux server will return nil.
  local gui = wezterm.gui
  if gui then
    local appearance = gui.get_appearance()
    if appearance:find "Dark" then
      return "Builtin Dark"
    else
      return "Builtin Light"
    end
  end
end

function updatePowerlineGoAppearance()
  helpers.set_appearance(wezterm.gui, powerlineGoAppearanceFile)
  wezterm.time.call_after(60, updatePowerlineGoAppearance)
end

wezterm.time.call_after(60, updatePowerlineGoAppearance)

-- Format window title like `[1/2]: ~/dev` or `[2/2]: vi ~/.config/wezterm/wezterm.lua`
wezterm.on('format-window-title', helpers.format_window_title)

-- Format tab titles like `1: ~/dev` or `2: vi`
wezterm.on('format-tab-title', helpers.format_tab_title)

local keys = {
  -- Forward `Cmd+key` commands to the terminal
  -- Make Cmd-Left equivalent to Home
  {key="LeftArrow", mods="SUPER", action=wezterm.action.SendKey{key='Home'}},
  -- Make Cmd-Right equivalent to End
  {key="RightArrow", mods="SUPER", action=wezterm.action.SendKey{key='End'}},
  -- Make Cmd+Enter go to fullscreen
  {key="Enter", mods="SUPER", action=wezterm.action.ToggleFullScreen},
  {key='0', mods='CTRL', action=wezterm.action.ResetFontAndWindowSize},
}

if (wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin') then
  table.insert(keys, {key='3', mods='OPT', action=wezterm.action.SendKey{key='#'}})
end


return {
  color_scheme = scheme_for_appearance(),
  exit_behavior = "Close",
  initial_cols = 152,
  initial_rows = 34,
  detect_password_input = true,
  enable_scroll_bar = true,
  native_macos_fullscreen_mode = true,
  scrollback_lines = 100000,
  window_padding = {
    left = '0',
    right = '1cell',
    top = '0',
    bottom = '0',
  },
  window_close_confirmation = "NeverPrompt",
  use_resize_increments = true,

  -- Cursor is a slow blinking block
  cursor_blink_rate = 1000,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  animation_fps = 1,
  default_cursor_style = "BlinkingBlock",

  -- Font configuration to be like GoLand, IntelliJ, etc.
  font = wezterm.font "JetBrains Mono", -- Font baked into WezTerm
  font_size = 13.0,
  line_height = 1.2,

  keys = keys,

--  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
}
