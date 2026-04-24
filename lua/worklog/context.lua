local blocks = require("worklog.blocks")

local M = {}

local function build_context(lines, block)
  if not block then
    return nil
  end

  return {
    lines = lines,
    block = block,
    body_lines = blocks.get_body_lines(lines, block),
  }
end

function M.get_active_worklog_context(lines)
  local parsed = blocks.parse(lines)
  local block = blocks.get_active_worklog(parsed)
  return build_context(lines, block)
end

function M.get_worklog_context_at_row(lines, row)
  local parsed = blocks.parse(lines)
  local block = blocks.get_worklog_at_row(parsed, row)
  return build_context(lines, block)
end

return M
