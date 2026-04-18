# worklog.nvim

Small Neovim plugin for keeping a plain-text worklog.

Write timestamped lines in a buffer:

```text
08:04 planning
08:53 implementation
13:00 doctor #ooo
16:00 done
```

- each line runs until the next timestamp
- `#ooo` means out of office and is excluded from `workday`
- non-timestamped lines are ignored
- the latest `--- worklog ---` block is always the active one

## Commands

- `:WorklogInsert` - insert the current time at the cursor
- `:WorklogCopy` - append a fresh `--- worklog ---` block from the active worklog
- `:WorklogSummarize` - append exact summary totals
- `:WorklogQuantSum` - append grouped totals rounded to 15-minute blocks

## Workflow

Start with raw notes:

```text
08:04 planning
08:53 implementation
13:00 doctor #ooo
16:00 done
```

Copy the active worklog when you want to refine it manually:

```vim
:WorklogCopy
```

That appends:

```text
--- worklog ---
08:04 planning
08:53 implementation
13:00 doctor #ooo
16:00 done
```

Then add summaries from the active worklog block:

```vim
:WorklogSummarize
```

- uses exact interval durations
- best when you want the real totals

```vim
:WorklogQuantSum
```

- groups identical items first
- rounds the grouped totals together to 15-minute blocks
- keeps `#ooo` handling the same as the exact summary

`WorklogQuantSum` groups identical items first, rounds the total activity time to
the nearest 15 minutes, rounds each grouped item down to 15-minute blocks, and
then distributes the remaining 15-minute blocks to the largest remainders.

This keeps the quantized summary close to the exact total while making the
displayed grouped totals add up cleanly.

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
