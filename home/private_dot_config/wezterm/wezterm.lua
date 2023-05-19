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

wezterm.time.call_after(
  60,
  function()
    -- The multiplexer may not be connected to a GUI, so attempting to resolve this module from the mux server will return nil.
    local gui = wezterm.gui
    if gui then
      local appearance = gui.get_appearance()

      local f = io.open(powerlineGoAppearanceFile, "r")
      local existing = f:read("*a")
      f:close()

      local current = "light"
      if appearance:find "Dark" then
        current = "dark"
      end

      if current ~= existing then
        local f = io.open(powerlineGoAppearanceFile, "w+")
        f:write(current)
        f:flush()
        f:close()
      end
    end
  end
)

-- Format window title like `[1/2]: ~/dev` or `[2/2]: vi ~/.config/wezterm/wezterm.lua`
wezterm.on(
  'format-window-title',
  function(tab, pane, tabs, panes, config)
    local program = pane.user_vars["WEZTERM_PROG"]
    if program == nil then
      program = ""
    end

    local ssh = ""
    if pane.user_vars["WEZTERM_SSH"] == "true" then
      local suffix = ":"
      if program == "" then
        suffix = " "
      end
      ssh = string.format('%s@%s%s', pane.user_vars["WEZTERM_USER"], pane.user_vars["WEZTERM_HOST"], suffix)
    end

    if program == "" then
      program = helpers.remove_file_prefix(tab.active_pane.current_working_dir, pane.user_vars["WEZTERM_HOME"])
    end

    local index = ''
    if #tabs > 1 then
      index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
    end

    return  index .. ssh .. program
  end
)

-- Format tab titles like `1: ~/dev` or `2: vi`
wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local program = helpers.basename(tab.active_pane.user_vars["WEZTERM_PROG"])
    local ssh = ""
    if tab.active_pane.user_vars["WEZTERM_SSH"] == "true" then
      local suffix = ":"
      if program == "" then
        suffix = " "
      end
      ssh = string.format('%s@%s%s', tab.active_pane.user_vars["WEZTERM_USER"], tab.active_pane.user_vars["WEZTERM_HOST"], suffix)
    end

    if program == "" then
      program = helpers.remove_file_prefix(tab.active_pane.current_working_dir, tab.active_pane.user_vars["WEZTERM_HOME"])
    end

    local index = string.format('%d: ', tab.tab_index + 1)

    -- Documentation on the format is at https://wezfurlong.org/wezterm/config/lua/wezterm/format.html
    local title = {}

    local unseen = ""
    if tab.active_pane.has_unseen_output then
      title[#title + 1] = { Background = { Color = 'blue' } }
      unseen = ' *'
    -- TODO use https://wezfurlong.org/wezterm/config/lua/wezterm.time/now.html to change the background to blue and
    -- back over time, highlighting the change? https://github.com/kikito/tween.lua?
    end

    title[#title + 1] = { Text = ' ' .. unseen .. index .. ssh .. program .. ' ' }

    return title
  end
)

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
    -- Make Cmd+Enter go to fullscreen
    {key="Enter", mods="SUPER", action=wezterm.action.ToggleFullScreen},
    {key='0', mods='CTRL', action=wezterm.action.ResetFontAndWindowSize},
  },

--  window_decorations = "RESIZE",
}
