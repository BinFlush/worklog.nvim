local M = {}

function M.is_time_line(line)
  return line:match("^%d%d:%d%d") ~= nil
end

function M.parse_time_line(line)
  local hh, mm, rest = line:match("^(%d%d):(%d%d)%s+(.+)$")
  if not hh then
    return nil
  end

  local minutes = tonumber(hh) * 60 + tonumber(mm)
  local excluded = rest:match("#ooo") ~= nil

  rest = rest:gsub("%s*#ooo%s*", " ")
  rest = rest:gsub("%s+", " ")
  rest = rest:gsub("^%s+", "")
  rest = rest:gsub("%s+$", "")

  return {
    minutes = minutes,
    text = rest,
    excluded = excluded,
  }
end

function M.parse_lines(lines)
  local entries = {}

  for _, line in ipairs(lines) do
    if M.is_time_line(line) then
      local entry = M.parse_time_line(line)
      if entry then
        table.insert(entries, entry)
      end
    end
  end

  return entries
end

return M
