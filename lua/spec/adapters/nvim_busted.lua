local busted = require "spec.adapters.busted"

local adapter = {
  name = "nvim_busted",
  command = "nvim -l scripts/busted.lua -o json ",
  parse_output = busted.parse_output,
  get_tests = busted.get_tests,
}

function adapter.is_enabled()
  return vim.fn.filereadable "scripts/busted.lua" == 1
end

function adapter.cursor_command()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  for _, test in ipairs(adapter.get_tests()) do
    if row >= test.context.start_row and row <= test.context.end_row then
      return adapter.command .. "--filter " .. vim.fn.shellescape(test.full_name) .. " " .. vim.fn.expand "%", { test }
    end
  end

  return nil
end

function adapter.file_command()
  return adapter.command .. vim.fn.expand "%", adapter.get_tests()
end

return adapter
