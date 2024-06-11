local test_finder = require "spec.test_finder"

local rspec_query = vim.treesitter.query.parse("ruby", require "spec.adapters.rspec_query")
local rspec_command = "RSPEC_COVERAGE=0  bundle exec rspec --format json "

local adapter = {
  name = "rspec",
}

function adapter.is_enabled()
  return vim.fn.executable "bundle" == 1 and string.find(vim.fn.expand "%", "_spec.rb$") ~= nil
end

function adapter.parse_output(line)
  local points = {}
  local ok, decoded = pcall(vim.fn.json_decode, line)
  if not ok then
    return points
  end

  for _, example in ipairs(decoded.examples) do
    if example.status == "failed" or example.status == "passed" then
      table.insert(points, {
        file = example.file_path,
        status = example.status,
        message = (example.exception and example.exception.message or ""):match "([^\n]*)\n?",
        full_message = (example.exception and example.exception.message or ""),
        line = example.line_number,
        column = 0,
      })
    end
  end

  return points
end

function adapter.get_tests()
  return test_finder("ruby", rspec_query)
end

function adapter.cursor_command()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  -- Test to see if a test is in the current position
  for _, test in ipairs(adapter.get_tests()) do
    if row >= test.context.start_row and row <= test.context.end_row then
      return rspec_command .. vim.fn.expand "%" .. ":" .. test.context.start_row + 1, { test }
    end
  end

  return nil
end

function adapter.file_command()
  return rspec_command .. vim.fn.expand "%", adapter.get_tests()
end

return adapter
