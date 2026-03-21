local M = {}

local function round_to_nearest_15(minutes)
  return math.floor((minutes + 7.5) / 15) * 15
end

function M.entries(entries)
  local result = {}

  for _, entry in ipairs(entries) do
    table.insert(result, {
      minutes = round_to_nearest_15(entry.minutes),
      text = entry.text,
      excluded = entry.excluded,
    })
  end

  return result
end

return M
