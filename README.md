# ai-mention.nvim

Select lines of code in Visual, Visual Line, or Visual Block mode to copy a file-and-line reference to the clipboard. The code itself is not copied.

By default, selecting lines 12–15 in `lua/example.lua` copies `@lua/example.lua:12-15` (or `@lua/example.lua:12` for one line). Paths are relative to Neovim's current working directory; files outside it use absolute paths. With the optional full-path mapping below, the same selection copies a path such as `@/home/user/project/lua/example.lua:12-15`.

## Requirements

- Neovim with a working `+` clipboard provider (run `:checkhealth vim.provider` if clipboard access fails).
- A saved file with a path.

## Installation

### lazy.nvim

Add this entry to your lazy.nvim plugin list:

```lua
{
  "akunbeben/ai-mention",
  keys = {
    {
      "<leader>am",
      function() require("ai_mention").copy() end,
      mode = "x",
      desc = "Copy AI file mention",
    },
    {
      "<leader>aM",
      function() require("ai_mention").copy({ full_path = true }) end,
      mode = "x",
      desc = "Copy AI file mention with full path",
    },
  },
}
```

### Without a plugin manager

On macOS or Linux, install it as a native Neovim package:

```sh
mkdir -p ~/.local/share/nvim/site/pack/ai-mention/start
git clone https://github.com/akunbeben/ai-mention.git ~/.local/share/nvim/site/pack/ai-mention/start/ai-mention
```

Add the visual mapping to `~/.config/nvim/init.lua`:

```lua
vim.keymap.set("x", "<leader>am", function() require("ai_mention").copy() end, { desc = "Copy AI file mention" })
vim.keymap.set("x", "<leader>aM", function() require("ai_mention").copy({ full_path = true }) end, { desc = "Copy AI file mention with full path" })
```

Set `vim.g.mapleader` (if you use it) **before** defining the keymaps. For example, `vim.g.mapleader = " "` makes `<leader>am` into `Space a m`. Change either shortcut to your preferred keys, or omit the mapping you do not need.

## Usage

1. Open a saved file.
2. Select lines with `V` and move the cursor. `v` and `Ctrl-V` also work.
3. Press `<leader>am` for a path relative to Neovim's working directory, or `<leader>aM` for the full absolute path.
4. Paste into your AI harness. The reference has the form `@path/to/file:first-line-last-line`. To inspect the clipboard in Neovim, run `:echo getreg('+')`.

## Integration

Each successful copy emits the Neovim `User` autocmd event `AiMentionCopied` **after** writing to the `+` clipboard. Other Neovim plugins or integrations can subscribe:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "AiMentionCopied",
  callback = function(event)
    local data = event.data
    -- data.mention, data.file, data.first_line, data.last_line, data.full_path
    print(data.mention)
  end,
})
```

`file` is the absolute buffer path; `first_line` and `last_line` are 1-based inclusive numbers; `full_path` indicates which mention format was copied. No event fires when the buffer has no file path or clipboard writing fails. Neovim `User` events are local to that Neovim instance; standalone apps need a Neovim-side bridge or can read the clipboard.

## Verification

From the plugin directory:

```sh
nvim --headless -u NONE -i NONE -l tests/visual.lua
```
