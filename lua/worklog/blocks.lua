local M = {}

local function is_header(line)
  return line:match("^%-%-%- .+ %-%-%-$") ~= nil
end

local function is_worklog_header(line)
  return line == "--- worklog ---"
end

-- Return the lines from the latest worklog block.
-- If no explicit worklog block exists, treat the entire file as the worklog.
function M.get_last_worklog_lines(lines)
  local last_worklog_start = nil

  for i, line in ipairs(lines) do
    if is_worklog_header(line) then
      last_worklog_start = i
    end
  end

  if not last_worklog_start then
    return lines
  end

  local result = {}

  for i = last_worklog_start + 1, #lines do
    local line = lines[i]
    if is_header(line) then
      break
    end
    table.insert(result, line)
  end

  return result
end

return M
