-- Test to see if we have baleia installed. If we do we can use it to highlight
-- ansi colors from command output.
local has_baleia, baleia = pcall(function()
  return require("baleia").setup { name = "SpecColors" }
end)

-- Highlight the buffer using baleia if it is installed.
local highlight_buffer = function(buf)
  if has_baleia then
    baleia.once(buf)
  end
end

local function view_error()
  local point = vim.api.nvim_win_get_cursor(0)
  local diagnostics = vim.diagnostic.get(0, { lnum = point[1] - 1 })

  if #diagnostics == 0 or #diagnostics[1]["user_data"]["full_message"] == nil then
    vim.notify "No spec error found at cursor"
    return
  end

  local user_data = diagnostics[1]["user_data"]

  vim.cmd [[edit /tmp/spec.results]]
  vim.api.nvim_buf_set_option(0, "filetype", "results")
  vim.api.nvim_buf_set_var(0, "bufftype", "nofile")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.split(user_data["full_message"], "\n"))
  highlight_buffer(0)
  vim.cmd "write"
end

return view_error
