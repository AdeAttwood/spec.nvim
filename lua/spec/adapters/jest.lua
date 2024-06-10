local test_finder = require "spec.test_finder"

local jest_query = vim.treesitter.query.parse("javascript", require "spec.adapters.jest_query")
local jest_command = "CI=true FORCE_COLOR=false jest --maxWorkers=25\\% --testLocationInResults --ci  --json "

local adapter = {
  name = "jest",
}

function adapter.is_enabled()
  return vim.fn.executable "jest" == 1
end

function adapter.parse_output(line)
  local points = {}
  local ok, decoded = pcall(vim.fn.json_decode, line)
  if not ok then
    return points
  end

  for _, testResult in ipairs(decoded.testResults) do
    local file = testResult.name
    for _, test in ipairs(testResult.assertionResults) do
      if test.status == "failed" or test.status == "passed" then
        table.insert(points, {
          file = file,
          status = test.status,
          message = (test.failureMessages[1] or ""):match "([^\n]*)\n?",
          full_message = test.failureMessages[1] or "",
          line = test.location.line,
          column = test.location.column,
        })
      end
    end
  end

  return points
end

function adapter.get_tests()
  return test_finder("javascript", jest_query)
end

function adapter.cursor_command()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  -- Test to see if a test is in the current position
  for _, test in ipairs(adapter.get_tests()) do
    if row >= test.context.start_row and row <= test.context.end_row then
      return jest_command .. "-t " .. vim.fn.shellescape(test.full_name) .. " " .. vim.fn.expand "%", { test }
    end
  end

  return nil
end

function adapter.file_command()
  return jest_command .. vim.fn.expand "%", adapter.get_tests()
end

return adapter
