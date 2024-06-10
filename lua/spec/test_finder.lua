---@class Range
---@field start_row number
---@field start_col number
---@field end_row number
---@field end_col number

---@class Test
---@field name string
---@field full_name string
---@field test Range
---@field context Range

---@class PartialTest
---@field name string
---@field full_name string
---@field test Range
---@field context Range

---@param node TSNode
---@return Range
local function node_to_range(node)
  local start_row, start_col, end_row, end_col = node:range()
  return {
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col,
  }
end

return function(language, test_query)
  local parser = vim.treesitter.get_parser(0, language)
  local tree, _ = unpack(parser:parse())

  local tests = {} ---@type (Test | PartialTest)[]
  local current_context = { { name = "", node = tree:root() } }

  for id, node in test_query:iter_captures(tree:root(), 0, 0, -1) do
    local capture_name = test_query.captures[id]

    if capture_name == "spec.context" then
      table.insert(current_context, { name = nil, node = node })
    end

    if capture_name == "spec.context_name" then
      local start_row, start_col, end_row, end_col = node:range()
      local content = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
      for i = 1, #current_context, 1 do
        if not current_context[i].name then
          current_context[i].name = table.concat(content, " ")
        end
      end
    end

    if capture_name == "spec.test" then
      table.insert(tests, { context = node_to_range(node) })
    end

    if capture_name == "spec.test_name" then
      local range = node_to_range(node)
      local content = vim.api.nvim_buf_get_text(0, range.start_row, range.start_col, range.end_row, range.end_col, {})

      local new_context = {}
      for i = 1, #current_context, 1 do
        if vim.treesitter.is_ancestor(current_context[i].node, node) then
          table.insert(new_context, current_context[i])
        end
      end
      current_context = new_context

      local prefix = ""
      for i = 1, #current_context, 1 do
        if current_context[i].name then
          prefix = prefix .. current_context[i].name .. " "
        end
      end

      local name = table.concat(content, " ")

      for i = 1, #tests, 1 do
        if not tests[i].name then
          tests[i].name = name
          tests[i].full_name = vim.fn.trim(prefix .. name)
          tests[i].test = node_to_range(node)
          break
        end
      end
    end
  end

  return tests
end
