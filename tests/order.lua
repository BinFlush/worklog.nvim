return function(t)
  local order = require("worklog.order")
  local parse = require("worklog.parse")

  t.test("parse items keeps preamble and normalizes trailing blank lines", function()
    local parsed = order.parse_items({
      "preamble",
      "17:00 later",
      "",
      "note later",
      "",
      "16:00 earlier",
      "",
      "",
      "",
    }, 10, parse.parse_time_line)

    t.eq(parsed.preamble_lines, { "preamble" })
    t.eq(#parsed.items, 2)
    t.eq(parsed.items[1].minutes, 1020)
    t.eq(parsed.items[1].row, 11)
    t.eq(parsed.items[1].text, "later")
    t.eq(parsed.items[1].lines, {
      "17:00 later",
      "",
      "note later",
    })
    t.eq(parsed.items[2].lines, {
      "16:00 earlier",
    })
  end)

  t.test("find unordered rows reports first decreasing pair", function()
    local parsed = order.parse_items({
      "08:30 later",
      "08:00 earlier",
      "09:00 done",
    }, 20, parse.parse_time_line)

    t.eq({ order.find_unordered_rows(parsed.items) }, { 20, 21 })
  end)

  t.test("normalized lines preserve order while stripping item trailing blanks", function()
    local parsed = order.parse_items({
      "preamble",
      "08:00 first",
      "note a",
      "",
      "08:30 second",
      "09:00",
      "",
    }, 1, parse.parse_time_line)

    t.eq(order.normalized_lines(parsed), {
      "preamble",
      "08:00 first",
      "note a",
      "08:30 second",
      "09:00",
    })
  end)

  t.test("sorted lines reorder items but keep attached lines", function()
    local parsed = order.parse_items({
      "preamble",
      "17:00 later",
      "",
      "note later",
      "",
      "16:00 earlier",
    }, 1, parse.parse_time_line)

    t.eq(order.sorted_lines(parsed), {
      "preamble",
      "16:00 earlier",
      "17:00 later",
      "",
      "note later",
    })
  end)

  t.test("sorted lines preserve equal timestamp order", function()
    local parsed = order.parse_items({
      "08:00 first",
      "note a",
      "08:00 second",
      "note b",
      "09:00 done",
    }, 1, parse.parse_time_line)

    t.eq(order.sorted_lines(parsed), {
      "08:00 first",
      "note a",
      "08:00 second",
      "note b",
      "09:00 done",
    })
  end)
end
