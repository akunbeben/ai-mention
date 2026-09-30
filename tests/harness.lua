vim.opt.rtp:append(vim.fn.getcwd())
local mention = require("ai_mention")
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
vim.fn.writefile({ "#!/bin/sh", "exec cat" }, temp .. "/pi")
vim.fn.writefile({ "#!/bin/sh", "exec cat" }, temp .. "/omp")
vim.fn.setfperm(temp .. "/omp", "rwxr-xr-x")
vim.fn.setfperm(temp .. "/pi", "rwxr-xr-x")
vim.env.PATH = temp .. ":" .. vim.env.PATH

local file = vim.fn.getcwd() .. "/example.lua"
vim.api.nvim_buf_set_name(0, file)
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one", "two" })
local source = vim.api.nvim_get_current_win()
local warnings = {}
vim.notify = function(msg) warnings[#warnings + 1] = msg end
vim.keymap.set("x", "x", function() mention.copy() end)
vim.keymap.set("x", "X", function() mention.copy({ full_path = true }) end)
local function select_lines(full_path)
  vim.api.nvim_set_current_win(source)
  vim.api.nvim_feedkeys(full_path and "ggVjX" or "ggVjx", "xt", false)
end
local function received(buf, text)
  return vim.wait(1000, function()
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):find(text, 1, true) ~= nil
  end, 10)
end

mention.setup({ harness = "pi" })
select_lines()
assert(vim.fn.getreg("+") == "@example.lua:1-2")
assert(warnings[#warnings]:find("no connected pi session", 1, true))

mention.open()
local first = vim.api.nvim_get_current_buf()
assert(vim.b[first].ai_mention_session.harness == "pi")
select_lines()
assert(received(first, "@example.lua:1-2"), "single session did not receive the mention")

mention.open()
local second = vim.api.nvim_get_current_buf()
assert(second ~= first)
local selected
vim.ui.select = function(items, _, callback)
  assert(#items == 2)
  selected = true
  callback(items[2])
end
select_lines(true)
assert(selected, "multiple sessions must show a picker")
assert(received(second, "@" .. file .. ":1-2"), "selected session did not receive the mention")
assert(not received(first, "@" .. file .. ":1-2"), "unselected session received the mention")

mention.setup({ harness = "omp" })
mention.open()
local omp_buf = vim.api.nvim_get_current_buf()
select_lines()
assert(received(omp_buf, "@example.lua:1-2"), "omp session did not receive the mention")
vim.fn.jobstop(vim.b[omp_buf].ai_mention_session.job)
mention.setup({ harness = "pi" })

vim.fn.jobstop(vim.b[first].ai_mention_session.job)
vim.fn.jobstop(vim.b[second].ai_mention_session.job)
select_lines()
assert(warnings[#warnings]:find("no connected pi session", 1, true))
vim.fn.delete(temp, "rf")
print("managed harness delivery: OK")
