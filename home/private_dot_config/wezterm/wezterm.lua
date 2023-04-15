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

function trim_prefix(s, prefix)
  if s:find(prefix, 1, true) then
    s = string.sub(s, string.len(prefix) + 1, string.len(s))
  end
  return s
end

function basename(s)
  -- test case # expected output
  -- cat # cat
  -- /usr/bin/cat # cat
  -- c:\\usr\\bin\\cat # cat
  -- sudo /usr/bin/cat # cat
  -- FOO=var cat # cat
  -- FOO=var BAR=var cat # cat
  -- sudo FOO=var cat # cat
  -- sudo FOO=var bash cat # cat
  -- sudo FOO=var bash # bash (that's the command being run)
  -- FOO cat # (should output FOO, which is the command going to be run)

  if (s == nil or s == "") then
    return ""
  end

  local name = ""
  for substring in string.gmatch(s, "%S+") do
    if not string.find(substring, "=") then
      if (substring ~= "sudo" and substring ~= "bash" and substring ~= "zsh") then
        -- The first occurrence of something that isn't an env. var. and isn't an ignored word, so must be
        -- the command being executed
        return string.gsub(s, '(.*[/\\])(.*)', '%2')
      end

      name = substring
    end
  end

  -- in case we're executing something like `sudo bash`
  return name
end

function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

function unescape(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

function remove_file_prefix(s, home)
  s = trim_prefix(s, 'file://')
  if (home ~= nil and s:find(home, 1, true)) then
    s = "~" .. trim_prefix(s, home)
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
      program = unescape(remove_file_prefix(tab.active_pane.current_working_dir, pane.user_vars["WEZTERM_HOME"]))
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
      program = unescape(remove_file_prefix(tab.active_pane.current_working_dir, tab.active_pane.user_vars["WEZTERM_HOME"]))
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
