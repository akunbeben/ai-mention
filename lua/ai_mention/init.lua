local M = {}

function M.copy(opts)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("AI mention: save the file before copying its reference", vim.log.levels.ERROR)
    return
  end

  local first = math.min(vim.fn.line("v"), vim.fn.line("."))
  local last = math.max(vim.fn.line("v"), vim.fn.line("."))
  local lines = first == last and tostring(first) or first .. "-" .. last
  local full_path = opts and opts.full_path or false
  local mention = "@" .. vim.fn.fnamemodify(path, full_path and ":p" or ":.") .. ":" .. lines
  vim.fn.setreg("+", mention)
  vim.api.nvim_exec_autocmds("User", {
    pattern = "AiMentionCopied",
    data = { mention = mention, file = path, first_line = first, last_line = last, full_path = full_path },
  })
end

return M
