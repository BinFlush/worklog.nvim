local blocks = require("worklog.blocks")
local parse = require("worklog.parse")
local intervals = require("worklog.intervals")
local summary = require("worklog.summary")
local render = require("worklog.render")

local M = {}

-- Insert the current time at the cursor and enter insert mode.
-- This is intentionally dumb and supports manual editing/refinement.
function M.insert_now()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local time = os.date("%H:%M")
  vim.api.nvim_buf_set_lines(0, row, row, false, { time .. " " })
  vim.api.nvim_win_set_cursor(0, { row + 1, #time + 1 })
  vim.cmd("startinsert!")
end

-- Read the latest worklog block from the current buffer.
-- All transformation commands operate on this active worklog.
local function get_active_worklog_lines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return blocks.get_last_worklog_lines(lines)
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

-- Append a summary and totals block based on the active worklog.
function M.append_summary()
  local ivs = get_active_intervals()
  local result = summary.summarize(ivs)
  local rendered = render.summary_lines(result, "exact")

  append_lines(rendered)
end

function M.append_quantized_summary()
  local ivs = get_active_intervals()
  local result = summary.quantized_summarize(ivs)
  local rendered = render.summary_lines(result, "quantized")

  append_lines(rendered)
end

function M.append_copy()
  local lines = get_active_worklog_lines()
  local rendered = render.worklog_lines(lines)
  append_lines(rendered)
end

function M.setup()
  vim.api.nvim_create_user_command("WorklogInsert", function()
    M.insert_now()
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
