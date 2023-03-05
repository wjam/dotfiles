local wezterm = require("wezterm")

return {
  color_scheme = "Wombat",
  exit_behavior = "Close",
  initial_cols = 140,
  initial_rows = 34,
  detect_password_input = true,
  window_background_opacity = 0.9,
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
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
  },

--  window_decorations = "RESIZE",
}
