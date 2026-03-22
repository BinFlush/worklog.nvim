local blocks = require("worklog.blocks")
local parse = require("worklog.parse")
local intervals = require("worklog.intervals")
local summary = require("worklog.summary")
local quantize = require("worklog.quantize")
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

local function show_in_new_buffer(value)
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.inspect(value), "\n"))
end

-- Read the latest worklog block from the current buffer.
-- All transformation commands operate on this active worklog.
local function get_active_worklog_lines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return blocks.get_last_worklog_lines(lines)
end

function M.parse_buffer()
  local lines = get_active_worklog_lines()
  local entries = parse.parse_lines(lines)
  show_in_new_buffer(entries)
end

function M.show_intervals()
  local lines = get_active_worklog_lines()
  local entries = parse.parse_lines(lines)
  local result = intervals.build(entries)
  show_in_new_buffer(result)
end

function M.show_summary()
  local lines = get_active_worklog_lines()
  local entries = parse.parse_lines(lines)
  local ivs = intervals.build(entries)
  local result = summary.summarize(ivs)
  show_in_new_buffer(result)
end

-- Append a summary and totals block based on the active worklog.
function M.append_summary()
  local lines = get_active_worklog_lines()
  local entries = parse.parse_lines(lines)
  local ivs = intervals.build(entries)
  local result = summary.summarize(ivs)
  local rendered = render.summary_lines(result)

  local last = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_buf_set_lines(0, last, last, false, rendered)
end

function M.show_quantized()
  local lines = get_active_worklog_lines()
  local entries = parse.parse_lines(lines)
  local result = quantize.entries(entries)
  show_in_new_buffer(result)
end

-- Append a new worklog block containing the quantized version
-- of the current active worklog.
function M.append_quantized()
  local lines = get_active_worklog_lines()
  local entries = parse.parse_lines(lines)
  local result = quantize.entries(entries)
  local rendered = render.worklog_lines(result)

  local last = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_buf_set_lines(0, last, last, false, rendered)
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", {
    debug = false,
  }, opts or {})

  vim.api.nvim_create_user_command("WorklogInsert", function()
    M.insert_now()
  end, {})

  vim.api.nvim_create_user_command("WorklogQuantize", function()
    M.append_quantized()
  end, {})

  vim.api.nvim_create_user_command("WorklogSummarize", function()
    M.append_summary()
  end, {})

  if M.opts.debug then
    vim.api.nvim_create_user_command("WorklogParse", function()
      M.parse_buffer()
    end, {})

    vim.api.nvim_create_user_command("WorklogIntervals", function()
      M.show_intervals()
    end, {})

    vim.api.nvim_create_user_command("WorklogSummary", function()
      M.show_summary()
    end, {})

    vim.api.nvim_create_user_command("WorklogQuantized", function()
      M.show_quantized()
    end, {})
  end
end
return M
