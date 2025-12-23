local wezterm = require 'wezterm'
local module = {}

-- https://wezterm.org/config/lua/wezterm/nerdfonts.html
local process_icons = {
  -- Remember to keep this list in sync with the list in loadWeztermHelpersLuaFunction
  ["cargo"] = wezterm.nerdfonts.dev_rust,
  ["docker"] = wezterm.nerdfonts.linux_docker,
  ["docker-compose"] = wezterm.nerdfonts.linux_docker,
  ["git"] = wezterm.nerdfonts.dev_git,
  ["go"] = wezterm.nerdfonts.seti_go2,
  ["kubectl"] = wezterm.nerdfonts.md_kubernetes,
  ["make"] = wezterm.nerdfonts.seti_makefile,
  ["man"] = wezterm.nerdfonts.fa_book,
  ["vi"] = wezterm.nerdfonts.md_file_edit,
  ["vim"] = wezterm.nerdfonts.md_file_edit,
  ["sleep"] = wezterm.nerdfonts.md_sleep,
  ["ssh"] = wezterm.nerdfonts.md_ssh,
}

function program_name(s)
  if (s == nil or s == "") then
    return ""
  end

  local name = ""
  for substring in string.gmatch(s, "%S+") do
    if not string.find(substring, "=") then
      if (substring ~= "sudo" and substring ~= "bash" and substring ~= "zsh") then
        -- The first occurrence of something that isn't an env. var. and isn't an ignored word, so must be
        -- the command being executed
        local prog = string.gsub(substring, '(.*[/\\])(.*)', '%2')
        return process_icons[prog] or prog
      end

      name = substring
    end
  end

  -- in case we're executing something like `sudo bash`
  return name
end

-- Turn the current working directory, which is a https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html, into
-- a string and replace $HOME with ~
function tidy_cwd(s, home)
  s = s.file_path
  if (home ~= nil and s:find(home, 1, true)) then
    s = "~" .. s:sub(home:len() + 1, s:len())
  end
  if s:sub(-1) == "/" then
    s = s:sub(1, -2)
  end
  return s
end

function execute(cmd)
  local handle = io.popen(cmd)
  local output = handle:read('*a')
  handle:close()

  return output:gsub('[\n\r]', ' ')
end

function module.set_powerline_appearance(gui, appearanceFile)
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

function module.set_btop_appearance(gui, lnk, light, dark)
  -- The multiplexer may not be connected to a GUI, so attempting to resolve this module from the mux server will return nil.
  if gui then
    local appearance = gui.get_appearance()

    existing = execute('readlink -f ' .. lnk)

    current = light
    if appearance:find "Dark" then
      current = dark
    end

    if current ~= existing then
      execute('ln -sf ' .. current .. ' ' .. lnk)
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

  if (program == "" and tab.active_pane.current_working_dir ~= nil) then
    program = tidy_cwd(tab.active_pane.current_working_dir, pane.user_vars["WEZTERM_HOME"])
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  return  index .. ssh .. program
end

function module.format_tab_title(tab, tabs, panes, config, hover, max_width)
    local program = program_name(tab.active_pane.user_vars["WEZTERM_PROG"])
    local ssh = ""
    if tab.active_pane.user_vars["WEZTERM_SSH"] == "true" then
      local suffix = ":"
      if program ~= "" then
        suffix = " "
      end
      ssh = string.format('%s@%s%s', tab.active_pane.user_vars["WEZTERM_USER"], tab.active_pane.user_vars["WEZTERM_HOST"], suffix)
    end

    if (program == "" and tab.active_pane.current_working_dir ~= nil) then
      program = tidy_cwd(tab.active_pane.current_working_dir, tab.active_pane.user_vars["WEZTERM_HOME"])
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
