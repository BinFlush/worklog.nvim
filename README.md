# worklog.nvim

Small Neovim plugin for keeping a plain-text worklog.

The format is deliberately simple: write timestamped lines in a buffer, then
append derived blocks from the latest worklog.

## Input Format

A worklog line starts with `HH:MM` followed by free text.

```text
08:04 bake strudel
08:21 negotiate with goose
08:33 bake strudel
08:52 coffee with ghost #ooo
09:11 polish trombone
09:36 bake strudel
10:00 done
```

- each entry lasts until the next timestamped entry
- non-timestamped lines (such as this one) are ignored
- `#ooo` marks an entry as out of office
- out-of-office entries are included in `activity`, but excluded from `workday`
- identical items are grouped by text and `#ooo` state during summary
- the final line is usually a closing marker such as `done`, so the previous
  item has an end time, but the exact text does not matter.

## Active Worklog

The plugin always operates on the active worklog.

- if the buffer contains one or more `--- worklog ---` headers, the latest one
  is the active worklog
- if there is no `--- worklog ---` header, the entire buffer is treated as the
  active worklog
- the active worklog ends at the next `--- ... ---` header, or at end of file

This makes it easy to keep raw notes at the top of the file and append derived
blocks below.

## Commands

### `:WorklogInsert`

Insert the current time at the cursor and enter insert mode.

Use this while logging live in a buffer.

### `:WorklogCopy`

Append a new `--- worklog ---` block containing the active worklog unchanged.

Use this when you want to iteratively refine timestamps or descriptions by hand while keeping
the previous version above as a reference.

### `:WorklogSummarize`

Append an exact grouped summary for the active worklog.

- intervals are computed from the original timestamps
- repeated items are grouped together
- output is rendered in decimal hours
- `activity` includes all grouped items
- `workday` excludes grouped items marked `#ooo`

### `:WorklogQuantSum`

Append a grouped summary whose item durations are quantized to 15-minute blocks.

- intervals are still computed from the original timestamps
- identical items are grouped before quantization
- output is rendered in decimal hours
- `activity` is the sum of all quantized grouped items
- `workday` is the sum of quantized grouped items not marked `#ooo`

## Quantized Summary Rules

`WorklogQuantSum` uses this algorithm:

1. compute exact intervals from the raw timestamps
2. group identical items by text and `#ooo` state
3. round the total `activity` time to the nearest 15 minutes
4. round each grouped item down to a 15-minute block
5. distribute the remaining 15-minute blocks to the largest remainders

This keeps the quantized summary close to the exact total while making the
displayed grouped totals add up cleanly.

One important consequence:

- non-`#ooo` grouped rows will always sum exactly to `workday`
- all grouped rows, including `#ooo`, participate in the same quantization pass

## Examples

### Example: exact grouped summary

Input worklog:

```text
08:04 bake strudel
08:21 negotiate with goose
08:33 bake strudel
08:52 coffee with ghost #ooo
09:11 polish trombone
09:36 bake strudel
10:00 done
```

`bake strudel` appears three times. The summary groups those intervals together and renders the result in decimal hours.

Exact summary:

```text
--- summary ---
1.00h bake strudel
0.20h negotiate with goose
0.32h coffee with ghost (ooo)
0.42h polish trombone

--- totals ---
1.93h activity
1.62h workday
```

Here:

- `activity` includes `coffee with ghost (ooo)`
- `workday` excludes it
- the row totals are exact, not rounded to 15-minute blocks

### Example: quantized grouped summary

Using the same input worklog `:WorklogQuantSum` appends:

```text
--- summary ---
1.00h bake strudel
0.25h negotiate with goose
0.25h coffee with ghost (ooo)
0.50h polish trombone

--- totals ---
2.00h activity
1.75h workday
```

Here:

- the exact `activity` total of `1.93h` is rounded to `2.00h`
- grouped items are rounded together, not one interval at a time
- the displayed grouped rows add up exactly to the displayed totals

### Example: copying a worklog block

Input buffer:

```text
08:04 bake strudel
08:21 negotiate with goose
08:33 bake strudel
10:00 done
```

After `:WorklogCopy`:

```text
08:04 bake strudel
08:21 negotiate with goose
08:33 bake strudel
10:00 done

--- worklog ---
08:04 bake strudel
08:21 negotiate with goose
08:33 bake strudel
10:00 done
```

The copied block becomes the latest `--- worklog ---` block, so later commands
operate on that block rather than on the whole buffer.

### Example: active worklog selection

Input buffer:

```text
08:00 draft potion recipe
09:00 done

--- worklog ---
08:15 bake strudel
08:45 mail wizard council
09:00 done

--- summary ---
0.50h bake strudel
0.25h mail wizard council

--- totals ---
0.75h activity
0.75h workday
```

The active worklog is:

```text
08:15 bake strudel
08:45 mail wizard council
09:00 done
```

The older lines at the top and the appended summary are ignored for the next
operation.

## Suggested Workflow

One simple workflow is:

1. jot down raw timestamped lines during the day
2. At the end of the day, use `:WorklogCopy` to create a new editable worklog block, if need be
3. adjust timestamps and texts in the copied block if needed
4. run `:WorklogSummarize` for exact totals
5. run `:WorklogQuantSum` when you want grouped 15-minute reporting totals

This keeps the source log simple while making refinement and reporting cheap.

## Install

Example with `lazy.nvim`:

```lua
{
  "BinFlush/worklog.nvim",
  config = function()
    require("worklog").setup()
  end,
}
```

