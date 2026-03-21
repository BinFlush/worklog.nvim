local M = {}

local function hours_string(minutes)
  return string.format("%.2fh", minutes / 60)
end

local function time_string(minutes)
  local hh = math.floor(minutes / 60)
  local mm = minutes % 60
  return string.format("%02d:%02d", hh, mm)
end

function M.worklog_lines(entries)
  local lines = {}

  table.insert(lines, "")
  table.insert(lines, "--- worklog ---")

  for _, entry in ipairs(entries) do
    local suffix = entry.excluded and " #ooo" or ""
    table.insert(lines, string.format("%s %s%s", time_string(entry.minutes), entry.text, suffix))
  end

  return lines
end

function M.summary_lines(summary)
  local lines = {}

  table.insert(lines, "")
  table.insert(lines, "--- summary ---")

  for _, item in ipairs(summary.items) do
    local suffix = item.excluded and " (ooo)" or ""
    table.insert(lines, string.format("%s %s%s", hours_string(item.duration), item.text, suffix))
  end

  table.insert(lines, "")
  table.insert(lines, "--- totals ---")
  table.insert(lines, string.format("%s activity", hours_string(summary.activity_total)))
  table.insert(lines, string.format("%s workday", hours_string(summary.workday_total)))

  return lines
end

return M
