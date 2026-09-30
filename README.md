# ai-mention.nvim

Select lines of code in Visual, Visual Line, or Visual Block mode to copy a file-and-line reference to the clipboard. The code itself is not copied.

Example: selecting lines 12–15 in `lua/example.lua` copies `@lua/example.lua:12-15`. A single line copies `@lua/example.lua:12`. Paths are relative to Neovim's current working directory; files outside it use absolute paths.

## Requirements

- Neovim with a working `+` clipboard provider (run `:checkhealth vim.provider` if clipboard access fails).
- A saved file with a path.

## Installation

### lazy.nvim

Add this entry to your lazy.nvim plugin list:

```lua
{
  "akunbeben/nvim-ai-mention",
  keys = {
    {
      "<leader>am",
      function() require("ai_mention").copy() end,
      mode = "x",
      desc = "Copy AI file mention",
    },
  },
}
```

### Without a plugin manager

On macOS or Linux, install it as a native Neovim package:

```sh
mkdir -p ~/.local/share/nvim/site/pack/ai-mention/start
git clone https://github.com/akunbeben/nvim-ai-mention.git ~/.local/share/nvim/site/pack/ai-mention/start/nvim-ai-mention
```

Add the visual mapping to `~/.config/nvim/init.lua`:

```lua
vim.keymap.set("x", "<leader>am", function() require("ai_mention").copy() end, { desc = "Copy AI file mention" })
```

Set `vim.g.mapleader` (if you use it) **before** defining the keymap. For example, `vim.g.mapleader = " "` makes the mapping `Space a m`. Change `<leader>am` to your preferred shortcut.

## Usage

1. Open a saved file.
2. Select lines with `V` and move the cursor. `v` and `Ctrl-V` also work.
3. Press `<leader>am` while the selection is active.
4. Paste into your AI harness. The reference has the form `@path/to/file:first-line-last-line`. To inspect the clipboard in Neovim, run `:echo getreg('+')`.

## Verification

From the plugin directory:

```sh
nvim --headless -u NONE -i NONE -l tests/visual.lua
```
