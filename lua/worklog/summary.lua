local M = {}

function M.summarize(intervals)
  local buckets = {}

  local activity_total = 0
  local workday_total = 0

  for _, iv in ipairs(intervals) do
    local key = iv.text .. "|" .. tostring(iv.excluded)

    if not buckets[key] then
      buckets[key] = {
        text = iv.text,
        duration = 0,
        excluded = iv.excluded,
      }
    end

    buckets[key].duration = buckets[key].duration + iv.duration

    activity_total = activity_total + iv.duration

    if not iv.excluded then
      workday_total = workday_total + iv.duration
    end
  end

  local items = {}

  for _, item in pairs(buckets) do
    table.insert(items, item)
  end

  return {
    items = items,
    activity_total = activity_total,
    workday_total = workday_total,
  }
end

return M
