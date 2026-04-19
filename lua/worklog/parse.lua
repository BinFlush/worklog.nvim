local M = {}

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
  local hh, mm, rest = line:match("^(%d%d):(%d%d)(.*)$")
  if not hh then
    return nil
  end

  if rest ~= "" and not rest:match("^%s") then
    return nil
  end

  hh = tonumber(hh)
  mm = tonumber(mm)

  if hh > 23 or mm > 59 then
    return nil
  end

  local minutes = hh * 60 + mm
  rest = rest:gsub("^%s+", "")
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
    local entry = M.parse_time_line(line)
    if entry then
      table.insert(entries, entry)
    end
  end

  return entries
end

return M
