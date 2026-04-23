return function(t)
  local blocks = require("worklog.blocks")

  t.test("parse implicit top worklog and explicit blocks", function()
    local parsed = blocks.parse({
      "08:00 raw",
      "09:00",
      "",
      "--- summary exact ---",
      "1.00h raw",
      "",
      "--- worklog ---",
      "10:00 tea",
      "11:00",
      "",
      "--- totals exact ---",
      "1.00h activity",
    })

    t.eq(#parsed, 4)
    t.eq(parsed[1].header, nil)
    t.eq(parsed[1].body_start_row, 1)
    t.eq(parsed[1].end_row, 4)
    t.eq(parsed[3].header, "--- worklog ---")
    t.eq(parsed[3].body_start_row, 8)
    t.eq(parsed[3].end_row, 11)
  end)

  t.test("worklog helpers identify active and cursor local worklogs", function()
    local parsed = blocks.parse({
      "08:00 raw",
      "09:00",
      "",
      "--- summary exact ---",
      "1.00h raw",
      "",
      "--- worklog ---",
      "10:00 tea",
      "11:00",
    })

    t.ok(blocks.is_worklog(parsed[1]))
    t.ok(blocks.is_worklog(parsed[3]))
    t.ok(not blocks.is_worklog(parsed[2]))
    t.eq(blocks.get_active_worklog(parsed), parsed[3])
    t.eq(blocks.get_worklog_at_row(parsed, 1), parsed[1])
    t.eq(blocks.get_worklog_at_row(parsed, 8), parsed[3])
    t.eq(blocks.get_worklog_at_row(parsed, 4), nil)
  end)

  t.test("body extraction and insert index", function()
    local lines = {
      "08:00 raw",
      "09:00",
      "",
      "--- worklog ---",
      "10:00 tea",
      "11:00",
      "",
      "--- totals exact ---",
      "1.00h activity",
    }
    local parsed = blocks.parse(lines)
    local body = blocks.get_body_lines(lines, parsed[2])

    t.eq(body, {
      "10:00 tea",
      "11:00",
      "",
    })
    t.eq(blocks.get_insert_index(parsed[2]), 7)
  end)

  t.test("trim empty lines removes leading and trailing blanks", function()
    local trimmed = blocks.trim_empty_lines({
      "",
      "",
      "08:00 raw",
      "09:00",
      "",
      "",
    })

    t.eq(trimmed, {
      "08:00 raw",
      "09:00",
    })
  end)
end
