local M = {}

local function hours_string(minutes)
  return string.format("%.2fh", minutes / 60)
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
