# worklog.nvim

Minimal Neovim plugin for tracking and refining a daily worklog in plain text.

---

## Usage

Write timestamped lines:

```
08:04 good morning
08:53 refinement
13:00 doctor #ooo
16:00 done
```

- each entry runs until the next  
- `#ooo` stands for "Out Of Office" is excluded from workday totals  
- non-timestamped lines are ignored  

---

## Workflow

```
:WorklogQuantize
```
→ appends a rounded `--- worklog ---` block

```
:WorklogSummarize
```
→ appends summary and totals

The **latest `--- worklog ---` block is always used**.

---

## Commands

- `:WorklogInsert` – insert current time  
- `:WorklogQuantize` – round times (15 min)  
- `:WorklogSummarize` – compute totals  

---

## Install (lazy.nvim)

```
{
  "BinFlush/worklog.nvim",
  config = function()
    require("worklog").setup()
  end,
}
```
