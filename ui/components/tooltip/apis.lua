---@type lib.callback
local callback = require "lib.callback"

local M = {}

M.SETUP_REACTIVE_FIELDS = callback.api({
    name = "framework.ui.components.tooltip.SetupReactiveFields",
})

M.SETUP_REACTIVE_LOGIC = callback.api({
    name = "framework.ui.components.tooltip.SetupReactiveLogic",
})

return M
