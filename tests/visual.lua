vim.opt.rtp:append(vim.fn.getcwd())
vim.g.mapleader = " "
vim.api.nvim_buf_set_name(0, vim.fn.getcwd() .. "/example.lua")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two", "three" })
vim.keymap.set("x", "<leader>am", require("ai_mention").copy)
vim.keymap.set("x", "<leader>aM", function() require("ai_mention").copy({ full_path = true }) end)
local copied, count
count = 0
vim.api.nvim_create_autocmd("User", {
  pattern = "AiMentionCopied",
  callback = function(event)
    assert(vim.fn.getreg("+") == event.data.mention, "event fired before clipboard write")
    copied = event.data
    count = count + 1
  end,
})

local function check(keys, expected, first, last, full_path)
  local before = count
  vim.api.nvim_feedkeys(keys, "xt", false)
  assert(vim.fn.getreg("+") == expected, vim.fn.getreg("+"))
  assert(count == before + 1, "expected exactly one copy event")
  assert(copied.mention == expected)
  assert(copied.file == vim.fn.getcwd() .. "/example.lua")
  assert(copied.first_line == first and copied.last_line == last)
  assert(copied.full_path == full_path)
end

check("ggVj am", "@example.lua:1-2", 1, 2, false)
check("\27GVk am", "@example.lua:2-3", 2, 3, false)
check("\27ggV am", "@example.lua:1", 1, 1, false)
check("\27GVk aM", "@" .. vim.fn.getcwd() .. "/example.lua:2-3", 2, 3, true)
print("visual mention clipboard and event: OK")
