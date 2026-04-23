local M = {}

local WORKLOG_HEADER = "--- worklog ---"

local function is_header(line)
  return line:match("^%-%-%- .+ %-%-%-$") ~= nil
end

local function is_worklog(block)
  return block.header == nil or block.header == WORKLOG_HEADER
end

function M.is_worklog(block)
  return is_worklog(block)
end

function M.parse(lines)
  local headers = {}

  for i, line in ipairs(lines) do
    if is_header(line) then
      table.insert(headers, {
        header = line,
        start_row = i,
        body_start_row = i + 1,
      })
    end
  end

  local blocks = {}

  if #headers == 0 then
    table.insert(blocks, {
      header = nil,
      start_row = 1,
      body_start_row = 1,
      end_row = #lines + 1,
    })
    return blocks
  end

  if headers[1].start_row > 1 then
    table.insert(blocks, {
      header = nil,
      start_row = 1,
      body_start_row = 1,
      end_row = headers[1].start_row,
    })
  end

  for i, block in ipairs(headers) do
    local next_block = headers[i + 1]

    block.end_row = next_block and next_block.start_row or (#lines + 1)
    table.insert(blocks, block)
  end

  return blocks
end

function M.get_active_worklog(blocks)
  local active = nil

  for _, block in ipairs(blocks) do
    if is_worklog(block) then
      active = block
    end
  end

  return active
end

function M.get_worklog_at_row(blocks, row)
  for _, block in ipairs(blocks) do
    if is_worklog(block) and row >= block.body_start_row and row < block.end_row then
      return block
    end
  end

  return nil
end

function M.get_body_lines(lines, block)
  local result = {}

  for i = block.body_start_row, block.end_row - 1 do
    table.insert(result, lines[i])
  end

  return result
end

function M.trim_empty_lines(lines)
  local start_index = 1
  local end_index = #lines

  while start_index <= #lines and lines[start_index] == "" do
    start_index = start_index + 1
  end

  while end_index >= start_index and lines[end_index] == "" do
    end_index = end_index - 1
  end

  local result = {}

  for i = start_index, end_index do
    table.insert(result, lines[i])
  end

  return result
end

function M.get_insert_index(block)
  return block.end_row - 1
end

return M
