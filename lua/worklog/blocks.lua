local M = {}

local function is_header(line)
  return line:match("^%-%-%- .+ %-%-%-$") ~= nil
end

local function is_worklog_header(line)
  return line == "--- worklog ---"
end

local function get_last_worklog_range(lines)
  local start_index = 1

  for i, line in ipairs(lines) do
    if is_worklog_header(line) then
      start_index = i + 1
    end
  end

  local stop_index = #lines + 1

  for i = start_index, #lines do
    if is_header(lines[i]) then
      stop_index = i
      break
    end
  end

  return start_index, stop_index
end

local function get_worklog_range_at(lines, row)
  local start_index = 1

  for i = 1, math.min(row - 1, #lines) do
    if is_worklog_header(lines[i]) then
      start_index = i + 1
    end
  end

  local stop_index = #lines + 1

  for i = start_index, #lines do
    if is_header(lines[i]) then
      stop_index = i
      break
    end
  end

  return start_index, stop_index
end

-- Return the lines from the latest worklog block.
-- If no explicit worklog block exists, treat the entire file as the worklog.
function M.get_last_worklog_lines(lines)
  local start_index, stop_index = get_last_worklog_range(lines)

  local result = {}

  for i = start_index, stop_index - 1 do
    local line = lines[i]
    table.insert(result, line)
  end

  return result
end

-- Return the 0-indexed insertion point at the end of the active worklog body.
function M.get_last_worklog_insert_index(lines)
  local _, stop_index = get_last_worklog_range(lines)
  return stop_index - 1
end

-- Return the 0-indexed insertion point at the end of the worklog body around `row`.
function M.get_worklog_insert_index_at(lines, row)
  local _, stop_index = get_worklog_range_at(lines, row)
  return stop_index - 1
end

return M
