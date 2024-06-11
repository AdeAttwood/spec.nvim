return [[
(call
  method: (identifier) @spec._function
  arguments: (argument_list
               (string
                 (string_content) @spec.context_name))
  (#match? @spec._function "(describe|context)")  ) @spec.context

(call
  method: (identifier) @spec._function
  arguments: (argument_list
               (string
                 (string_content) @spec.test_name))
  (#eq? @spec._function "it")  ) @spec.test
]]
