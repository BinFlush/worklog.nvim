local M = {}

-- A semantic worklog line starts with HH:MM.
function M.is_time_line(line)
  return line:match("^%d%d:%d%d") ~= nil
end

-- Clean and normalize the text part of a worklog entry.
-- - removes semantic tags like #ooo
-- - collapses whitespace
-- - trims leading/trailing spaces
local function normalize_text(text)
  text = text:gsub("%s*#ooo%s*", " ")
  text = text:gsub("%s+", " ")
  text = text:gsub("^%s+", "")
  text = text:gsub("%s+$", "")
  return text
end

-- Parse a single worklog line into structured data.
-- `#ooo` can appear anywhere in the text and marks the interval as excluded
-- from workday totals. The tag is removed from the stored text.
function M.parse_time_line(line)
  local hh, mm, rest = line:match("^(%d%d):(%d%d)%s+(.+)$")
  if not hh then
    return nil
  end

  local minutes = tonumber(hh) * 60 + tonumber(mm)
  local excluded = rest:match("#ooo") ~= nil

  rest = normalize_text(rest)

  return {
    minutes = minutes,
    text = rest,
    excluded = excluded,
  }
end

-- Parse all semantic worklog lines from a list of lines.
-- -- Returns a list of entries in chronological order:
-- {
--   { minutes = number, text = string, excluded = boolean },
--   ...
-- }
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
