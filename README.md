# lumen.nvim

Neovim plugin for opening [lumen](https://github.com/jnsahaj/lumen) in a floating terminal window.

## Requirements

- Neovim >= 0.8
- [lumen](https://github.com/jnsahaj/lumen) installed and in your `$PATH`

## Install

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "saiashirwad/lumen.nvim",
    cmd = { "LumenDiff", "LumenDiffCurrentFile" },
    keys = {
        { "<leader>ld", "<cmd>LumenDiff<cr>", desc = "Lumen Diff" },
        { "<leader>lf", "<cmd>LumenDiffCurrentFile<cr>", desc = "Lumen Diff (current file)" },
    },
    opts = {},
}
```

## Commands

`:LumenDiff [args]` — open `lumen diff` in a floating window. All arguments are passed through.

```
:LumenDiff
:LumenDiff HEAD~1
:LumenDiff main..feature
:LumenDiff --pr 123
:LumenDiff --watch
:LumenDiff --stacked main..feature
```

`:LumenDiffCurrentFile [args]` — same as `:LumenDiff`, but focuses the file in the current buffer via `--focus`.

## Configuration

All options and their defaults:

```lua
require("lumen").setup({
    floating_window = {
        fullscreen = false,
        scaling_factor = 0.9,   -- ignored when fullscreen = true
        winblend = 0,
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
})
```

With lazy.nvim, pass these as `opts`:

```lua
{
    "saiashirwad/lumen.nvim",
    cmd = { "LumenDiff", "LumenDiffCurrentFile" },
    keys = {
        { "<leader>ld", "<cmd>LumenDiff<cr>", desc = "Lumen Diff" },
        { "<leader>lf", "<cmd>LumenDiffCurrentFile<cr>", desc = "Lumen Diff (current file)" },
    },
    opts = {
        floating_window = {
            fullscreen = true,
        },
    },
}
```

## Highlight Groups

- `LumenBorder` — floating window border (default: links to `Normal`)
- `LumenFloat` — floating window background (default: links to `Normal`)

## License

MIT
