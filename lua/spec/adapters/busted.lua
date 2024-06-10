local test_finder = require "spec.test_finder"

local busted_query = vim.treesitter.query.parse("lua", require "spec.adapters.busted_query")

local adapter = {
  name = "busted",
  command = "busted -o json ",
}

function adapter.is_enabled()
  return vim.fn.filereadable ".busted" == 1
end

function adapter.parse_output(line)
  local points = {}
  local ok, decoded = pcall(vim.fn.json_decode, line)
  if not ok then
    return points
  end

  local function parse(status, parsed)
    return {
      file = parsed.element.trace.source,
      status = status,
      message = parsed.message or "",
      full_message = parsed.message or "",
      line = parsed.element.trace.currentline,
      column = 0,
    }
  end

  for _, success in ipairs(decoded.successes) do
    table.insert(points, parse("passed", success))
  end

  for _, fail in ipairs(decoded.failures) do
    table.insert(points, parse("failed", fail))
  end

  for _, error in ipairs(decoded.errors) do
    table.insert(points, parse("failed", error))
  end

  return points
end

function adapter.get_tests()
  return test_finder("lua", busted_query)
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
