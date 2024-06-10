local jest = require "spec.adapters.jest"
local busted = require "spec.adapters.busted"

local core = {
  current_adapter = jest,
  adapters = { busted, jest },
  spec_namespace = vim.api.nvim_create_namespace "spec",
}

function core.get_adapter()
  for _, adapter in ipairs(core.adapters) do
    if adapter.is_enabled() then
      return adapter
    end
  end

  return core.current_adapter
end

return core
