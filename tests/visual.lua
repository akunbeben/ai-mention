vim.opt.rtp:append(vim.fn.getcwd())
vim.g.mapleader = " "
vim.api.nvim_buf_set_name(0, vim.fn.getcwd() .. "/example.lua")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
vim.keymap.set("x", "<leader>am", require("ai_mention").copy)

local function check(keys, expected)
  vim.api.nvim_feedkeys(keys, "xt", false)
  assert(vim.fn.getreg("+") == expected, vim.fn.getreg("+"))
end

check("ggVj am", "@example.lua:1-2")
check("\27GVk am", "@example.lua:2-3")
check("\27ggV am", "@example.lua:1")
print("visual mention clipboard: OK")
