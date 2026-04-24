local M = {}

local function trim_trailing_empty_lines(lines)
  local end_index = #lines

  while end_index > 0 and lines[end_index] == "" do
    end_index = end_index - 1
  end

  local result = {}

  for i = 1, end_index do
    table.insert(result, lines[i])
  end

  return result
end

local function finalize_item(item)
  if not item then
    return nil
  end

  item.lines = trim_trailing_empty_lines(item.lines)
  return item
end

function M.parse_items(lines, start_row, parse_time_line)
  local preamble_lines = {}
  local items = {}
  local current = nil

  for i, line in ipairs(lines) do
    local entry = parse_time_line(line)

    if entry then
      current = finalize_item(current)
      if current then
        table.insert(items, current)
      end

      current = {
        minutes = entry.minutes,
        text = entry.text,
        excluded = entry.excluded,
        row = start_row + i - 1,
        index = #items + 1,
        lines = { line },
      }
    elseif current then
      table.insert(current.lines, line)
    else
      table.insert(preamble_lines, line)
    end
  end

  current = finalize_item(current)
  if current then
    table.insert(items, current)
  end

  return {
    preamble_lines = preamble_lines,
    items = items,
  }
end

function M.find_unordered_rows(items)
  for i = 2, #items do
    if items[i].minutes < items[i - 1].minutes then
      return items[i - 1].row, items[i].row
    end
  end

  return nil
end

function M.get_insert_row(items, minutes, default_row)
  for _, item in ipairs(items) do
    if item.minutes > minutes then
      return item.row - 1
    end
  end

  return default_row
end

local function rebuild_lines(preamble_lines, items)
  local lines = {}

  for _, line in ipairs(preamble_lines) do
    table.insert(lines, line)
  end

  for _, item in ipairs(items) do
    for _, line in ipairs(item.lines) do
      table.insert(lines, line)
    end
  end

  return trim_trailing_empty_lines(lines)
end

function M.normalized_lines(parsed)
  return rebuild_lines(parsed.preamble_lines, parsed.items)
end

function M.sorted_lines(parsed)
  local items = vim.deepcopy(parsed.items)

  table.sort(items, function(a, b)
    if a.minutes == b.minutes then
      return a.index < b.index
    end

    return a.minutes < b.minutes
  end)

  return rebuild_lines(parsed.preamble_lines, items)
end

return M
