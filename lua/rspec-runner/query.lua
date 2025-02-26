return [[
  (
    (call
      method: (identifier) @method_name
      (#match? @method_name "(describe|context|it)")
      arguments: (argument_list (string (string_content) @test_name))
    )
    @scope_root
  )
]]
