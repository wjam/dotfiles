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

function module.basename(s)
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

function module.unescape(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

function module.remove_file_prefix(s, home)
  s = trim_prefix(s, 'file://')
  if (home ~= nil and s:find(home, 1, true)) then
    s = "~" .. trim_prefix(s, home)
  end
  return s
end

return module
