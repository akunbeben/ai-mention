local M = {}
local harness

function M.setup(opts)
  if opts and opts.harness ~= nil and opts.harness ~= "pi" and opts.harness ~= "omp" then
    error("AI mention: harness must be 'pi' or 'omp'")
  end
  harness = opts and opts.harness or nil
end

function M.open()
  if not harness then
    vim.notify("AI mention: configure harness before opening a session", vim.log.levels.ERROR)
    return
  end
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, "ai-mention://" .. harness .. "/" .. buf)
  vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, buf)
  local job = vim.fn.termopen({ harness }, { cwd = vim.fn.getcwd() })
  if job <= 0 then
    vim.notify("AI mention: could not start " .. harness, vim.log.levels.ERROR)
    return
  end
  vim.b[buf].ai_mention_session = { harness = harness, job = job, cwd = vim.fn.getcwd() }
end

local function send(mention, file, full_path)
  local sessions = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local session = vim.b[buf].ai_mention_session
    if session and session.harness == harness and vim.fn.jobwait({ session.job }, 0)[1] == -1 then
      sessions[#sessions + 1] = { buf = buf, job = session.job, cwd = session.cwd }
    end
  end
  if #sessions == 0 then
    vim.notify("AI mention: no connected " .. harness .. " session; mention copied to clipboard", vim.log.levels.WARN)
    return
  end
  local function deliver(session)
    if vim.fn.jobwait({ session.job }, 0)[1] ~= -1 then
      vim.notify("AI mention: selected session has exited; mention copied to clipboard", vim.log.levels.WARN)
      return
    end
    local lines = mention:match(":%d+[%d%-]*$")
    local path = not full_path and vim.startswith(file, session.cwd .. "/")
      and file:sub(#session.cwd + 2) or file
    vim.api.nvim_chan_send(session.job, "@" .. path .. lines)
  end
  if #sessions == 1 then
    deliver(sessions[1])
  else
    vim.ui.select(sessions, {
      prompt = "Send mention to " .. harness .. " session:",
      format_item = function(session)
        return session.buf .. ": " .. session.cwd
      end,
    }, function(session)
      if session then deliver(session) end
    end)
  end
end
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
  if harness then send(mention, path, full_path) end
end

return M
