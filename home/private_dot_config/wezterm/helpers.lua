local module = {}

function trim_prefix(s, prefix)
  if s:find(prefix, 1, true) then
    s = string.sub(s, string.len(prefix) + 1, string.len(s))
  end
  return s
end

function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

function unescape(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

function basename(s)
  if (s == nil or s == "") then
    return ""
  end

  local name = ""
  for substring in string.gmatch(s, "%S+") do
    if not string.find(substring, "=") then
      if (substring ~= "sudo" and substring ~= "bash" and substring ~= "zsh") then
        -- The first occurrence of something that isn't an env. var. and isn't an ignored word, so must be
        -- the command being executed
        return string.gsub(substring, '(.*[/\\])(.*)', '%2')
      end

      name = substring
    end
  end

  -- in case we're executing something like `sudo bash`
  return name
end

function remove_file_prefix(s, home)
  s = trim_prefix(s, 'file://')
  s = unescape(s)
  if (home ~= nil and s:find(home, 1, true)) then
    s = "~" .. trim_prefix(s, home)
  end
  return s
end

function module.set_appearance(gui, appearanceFile)
  -- The multiplexer may not be connected to a GUI, so attempting to resolve this module from the mux server will return nil.
  if gui then
    local appearance = gui.get_appearance()

    local f = io.open(appearanceFile, "r")
    local existing = f:read("*a")
    f:close()

    local current = "light"
    if appearance:find "Dark" then
      current = "dark"
    end

    if current ~= existing then
      local f = io.open(appearanceFile, "w+")
      f:write(current)
      f:flush()
      f:close()
    end
  end
end

function module.format_window_title(tab, pane, tabs, panes, config)
  local program = pane.user_vars["WEZTERM_PROG"]
  if program == nil then
    program = ""
  end

  local ssh = ""
  if pane.user_vars["WEZTERM_SSH"] == "true" then
    local suffix = ":"
    if program ~= "" then
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

function module.format_tab_title(tab, tabs, panes, config, hover, max_width)
    local program = basename(tab.active_pane.user_vars["WEZTERM_PROG"])
    local ssh = ""
    if tab.active_pane.user_vars["WEZTERM_SSH"] == "true" then
      local suffix = ":"
      if program ~= "" then
        suffix = " "
      end
      ssh = string.format('%s@%s%s', tab.active_pane.user_vars["WEZTERM_USER"], tab.active_pane.user_vars["WEZTERM_HOST"], suffix)
    end

    if program == "" then
      program = remove_file_prefix(tab.active_pane.current_working_dir, tab.active_pane.user_vars["WEZTERM_HOME"])
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

return module
