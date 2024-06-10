return [[
(function_call
    name: (identifier) @spec._function
    arguments: (arguments
      (string
        content: (string_content) @spec.context_name))
  (#eq? @spec._function "describe")) @spec.context

(function_call
    name: (identifier) @spec._function
    arguments: (arguments
      (string
        content: (string_content) @spec.test_name))
  (#eq? @spec._function "it")) @spec.test
]]
