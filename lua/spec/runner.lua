local core = require "spec.core"

local function run(adapter, command, tests)
  local buffer = vim.api.nvim_get_current_buf()
  vim.diagnostic.reset(core.spec_namespace, buffer)

  local marks = vim.api.nvim_buf_get_extmarks(buffer, core.spec_namespace, 0, -1, {})
  for _, mark in ipairs(marks) do
    vim.api.nvim_buf_del_extmark(buffer, core.spec_namespace, mark[1])
  end

  for _, test in ipairs(tests) do
    vim.api.nvim_buf_set_extmark(buffer, core.spec_namespace, test.context.start_row, 0, {
      id = test.context.start_row + 1,
      virt_text = { { " 󰑮 RUNNING ", "DiagnosticVirtualTextInfo" } },
      sign_text = "󰑮 ",
      sign_hl_group = "DiagnosticInfo",
    })
  end

  local diagnostics = {}

  vim.fn.jobstart(command, {
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        local points = adapter.parse_output(line)
        for _, point in ipairs(points) do
          if point.status == "failed" then
            vim.api.nvim_buf_del_extmark(buffer, core.spec_namespace, point.line)

            table.insert(diagnostics, {
              source = "spec",
              lnum = point.line - 1,
              col = point.column - 1,
              end_lnum = point.line - 1,
              end_col = point.column - 1,
              message = point.message,
              severity = vim.diagnostic.severity.ERROR,
              user_data = {
                full_message = point.full_message,
              },
            })
          else
            vim.api.nvim_buf_set_extmark(buffer, core.spec_namespace, point.line - 1, point.column - 1, {
              id = point.line,
              virt_text = { { "   PASS ", "DiagnosticVirtualTextOk" } },
              sign_text = " ",
              sign_hl_group = "DiagnosticSignOk",
            })
          end
        end
      end
    end,
    on_exit = function()
      vim.diagnostic.set(core.spec_namespace, buffer, diagnostics)
    end,
  })
end

local runner = {}

function runner.run_file()
  local adapter = core.get_adapter()
  local command, tests = adapter.file_command()

  run(adapter, command, tests)
end

function runner.run_at_cursor()
  local adapter = core.get_adapter()
  local command, tests = adapter.cursor_command()
  if not command then
    vim.notify "No test found at cursor"
    return
  end

  run(adapter, command, tests)
end

return runner
