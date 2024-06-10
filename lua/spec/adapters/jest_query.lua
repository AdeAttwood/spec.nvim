return [[
; describe context blocks
(call_expression
  function: (identifier) @spec._function
  arguments: (arguments (string (string_fragment) @spec.context_name))
  (#eq? @spec._function "describe")) @spec.context

; normal test decorations
(call_expression
  function: (identifier) @spec._function
  arguments: (arguments (string (string_fragment) @spec.test_name))
  (#match? @spec._function "(it|test)")) @spec.test

; test.each, it.each
(call_expression
      function: (call_expression
        function: (member_expression
          object: (identifier) @spec._object
          property: (property_identifier) @spec._property))
      arguments: (arguments
        (string (string_fragment) @spec.test_name))
  (#match? @spec._object "(it|test)")
  (#eq? @spec._property "each")) @spec.test

; describe.each
(call_expression
      function: (call_expression
        function: (member_expression
          object: (identifier) @spec._object
          property: (property_identifier) @spec._property))
      arguments: (arguments
        (string (string_fragment) @spec.context_name))
  (#eq? @spec._object "describe")
  (#eq? @spec._property "each")) @spec.context
]]
