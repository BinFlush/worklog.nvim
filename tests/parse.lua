return function(t)
  local parse = require("worklog.parse")

  t.test("parse line with text and ooo", function()
    local entry = parse.parse_time_line("08:04 bake strudel #ooo")
    t.eq(entry.minutes, 484)
    t.eq(entry.text, "bake strudel")
    t.eq(entry.excluded, true)
  end)

  t.test("parse bare timestamp", function()
    local entry = parse.parse_time_line("08:04")
    t.eq(entry.minutes, 484)
    t.eq(entry.text, "")
    t.eq(entry.excluded, false)
  end)

  t.test("parse timestamp with trailing spaces", function()
    local entry = parse.parse_time_line("08:04   ")
    t.eq(entry.minutes, 484)
    t.eq(entry.text, "")
    t.eq(entry.excluded, false)
  end)

  t.test("reject malformed suffix", function()
    t.eq(parse.parse_time_line("08:04x"), nil)
  end)

  t.test("reject invalid hours and minutes", function()
    t.eq(parse.parse_time_line("24:00 nope"), nil)
    t.eq(parse.parse_time_line("23:60 nope"), nil)
    t.eq(parse.parse_time_line("99:99 nope"), nil)
  end)

  t.test("parse lines ignores non semantic lines", function()
    local entries = parse.parse_lines({
      "08:00 first",
      "note",
      "08:30 second #ooo",
      "bad time 99:99",
      "09:00",
    })

    t.eq(entries, {
      {
        minutes = 480,
        text = "first",
        excluded = false,
      },
      {
        minutes = 510,
        text = "second",
        excluded = true,
      },
      {
        minutes = 540,
        text = "",
        excluded = false,
      },
    })
  end)
end
