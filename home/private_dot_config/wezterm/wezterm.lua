local wezterm = require("wezterm")

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

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
  if s == nil then
    return ""
  end
  i, j = string.find(s, ' ')
  if i ~= nil then
    s = string.sub(s, 1, i)
  end
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

function remove_file_prefix(s, home)
  if s:find('file://', 1, true) then
    s = string.sub(s, 8, string.len(s))
  end
  if (home ~= nil and s:find(home, 1, true)) then
    s = "~" .. string.sub(s, string.len(home) + 1, string.len(s))
  end
  return s
end

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
      program = remove_file_prefix(tab.active_pane.current_working_dir, pane.user_vars["WEZTERM_HOME"])
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
    local program = basename(tab.active_pane.user_vars["WEZTERM_PROG"])
    local ssh = ""
    if tab.active_pane.user_vars["WEZTERM_SSH"] == "true" then
      local suffix = ":"
      if program == "" then
        suffix = " "
      end
      ssh = string.format('%s@%s%s', tab.active_pane.user_vars["WEZTERM_USER"], tab.active_pane.user_vars["WEZTERM_HOST"], suffix)
    end

    if program == "" then
      program = remove_file_prefix(tab.active_pane.current_working_dir, tab.active_pane.user_vars["WEZTERM_HOME"])
    end

    local index = string.format('%d: ', tab.tab_index + 1)

    -- TODO check panes[*].has_unseen_output once https://github.com/wez/wezterm/issues/2625 is fixed
    return {
      { Text = ' ' .. index .. ssh .. program .. ' ' },
    }
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
