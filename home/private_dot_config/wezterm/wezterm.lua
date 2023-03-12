local wezterm = require("wezterm")

return {
  color_scheme = "3024 Night",
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

  -- Save tab history when closing
  unix_domains = {
    {
      name = 'unix',
    },
  },
  default_gui_startup_args = { 'connect', 'unix' },

  keys = {
    -- Forward `Cmd+key` commands to the terminal
    -- Make Cmd-Left equivalent to Home
    {key="LeftArrow", mods="SUPER", action=wezterm.action.SendKey{key='Home'}},
    -- Make Cmd-Right equivalent to End
    {key="RightArrow", mods="SUPER", action=wezterm.action.SendKey{key='End'}},
    {key='0', mods='CTRL', action=wezterm.action.ResetFontAndWindowSize},
  },

--  window_decorations = "RESIZE",
}
