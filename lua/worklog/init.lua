local blocks = require("worklog.blocks")
local order = require("worklog.order")
local parse = require("worklog.parse")
local intervals = require("worklog.intervals")
local summary = require("worklog.summary")
local render = require("worklog.render")

local M = {}

-- Read the latest worklog block from the current buffer.
-- All transformation commands operate on this active worklog.
local function get_active_worklog_lines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = blocks.parse(lines)
  local block = blocks.get_active_worklog(parsed)

  if not block then
    return {}
  end

  return blocks.get_body_lines(lines, block)
end

local function get_worklog_insert_index_at_cursor()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = blocks.parse(lines)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local block = blocks.get_worklog_at_row(parsed, row)

  if not block then
    return nil
  end

  return blocks.get_insert_index(block)
end

local function get_active_entries()
  local lines = get_active_worklog_lines()
  return parse.parse_lines(lines)
end

local function get_active_intervals()
  local entries = get_active_entries()
  return intervals.build(entries)
end

local function append_lines(lines)
  local last = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_buf_set_lines(0, last, last, false, lines)
end

local function format_entry_line(entry, time)
  local parts = { time }

  if entry.text ~= "" then
    table.insert(parts, entry.text)
  end

  if entry.excluded then
    table.insert(parts, "#ooo")
  end

  return table.concat(parts, " ")
end

local function warn_if_unordered_worklogs()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = blocks.parse(lines)

  for _, block in ipairs(parsed) do
    if blocks.is_worklog(block) then
      local body_lines = blocks.get_body_lines(lines, block)
      local parsed_body = order.parse_items(body_lines, block.body_start_row, parse.parse_time_line)
      local first_row, second_row = order.find_unordered_rows(parsed_body.items)

      if first_row then
        vim.notify(
          string.format(
            "worklog: unordered timestamps near lines %d and %d; fix manually or run :WorklogOrder",
            first_row,
            second_row
          ),
          vim.log.levels.WARN
        )
        return true
      end
    end
  end

  return false
end

-- Insert the current time at the cursor and enter insert mode.
-- This is intentionally dumb and supports manual editing/refinement.
function M.insert_now()
  if warn_if_unordered_worklogs() then
    return
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local time = os.date("%H:%M")
  vim.api.nvim_buf_set_lines(0, row, row, false, { time .. " " })
  vim.api.nvim_win_set_cursor(0, { row + 1, #time + 1 })
  vim.cmd("startinsert!")
end

-- Append a summary and totals block based on the active worklog.
function M.append_summary()
  if warn_if_unordered_worklogs() then
    return
  end

  local ivs = get_active_intervals()
  local result = summary.summarize(ivs)
  local rendered = render.summary_lines(result, "exact")

  append_lines(rendered)
end

function M.append_quantized_summary()
  if warn_if_unordered_worklogs() then
    return
  end

  local ivs = get_active_intervals()
  local result = summary.quantized_summarize(ivs)
  local rendered = render.summary_lines(result, "quantized")

  append_lines(rendered)
end

function M.append_copy()
  if warn_if_unordered_worklogs() then
    return
  end

  local lines = get_active_worklog_lines()
  local parsed = order.parse_items(lines, 1, parse.parse_time_line)
  local rendered = render.worklog_lines(order.normalized_lines(parsed))
  append_lines(rendered)
end

function M.repeat_current()
  if warn_if_unordered_worklogs() then
    return
  end

  local entry = parse.parse_time_line(vim.api.nvim_get_current_line())
  if not entry then
    vim.notify("worklog: current line is not a valid worklog entry", vim.log.levels.WARN)
    return
  end

  local line = format_entry_line(entry, os.date("%H:%M"))
  local insert_at = get_worklog_insert_index_at_cursor()
  if not insert_at then
    vim.notify("worklog: current line is not inside a worklog block", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, { line })
end

function M.order_worklogs()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local parsed = blocks.parse(lines)

  for i = #parsed, 1, -1 do
    local block = parsed[i]

    if blocks.is_worklog(block) then
      local body_lines = blocks.get_body_lines(lines, block)
      local parsed_body = order.parse_items(body_lines, block.body_start_row, parse.parse_time_line)
      local sorted_lines = order.sorted_lines(parsed_body)
      vim.api.nvim_buf_set_lines(0, block.body_start_row - 1, block.end_row - 1, false, sorted_lines)
    end
  end
end

function M.setup()
  vim.api.nvim_create_user_command("WorklogInsert", function()
    M.insert_now()
  end, {})

  vim.api.nvim_create_user_command("WorklogRepeat", function()
    M.repeat_current()
  end, {})

  vim.api.nvim_create_user_command("WorklogOrder", function()
    M.order_worklogs()
  end, {})

  vim.api.nvim_create_user_command("WorklogCopy", function()
    M.append_copy()
  end, {})

  vim.api.nvim_create_user_command("WorklogSummarize", function()
    M.append_summary()
  end, {})

  vim.api.nvim_create_user_command("WorklogQuantSum", function()
    M.append_quantized_summary()
  end, {})
end

return M
