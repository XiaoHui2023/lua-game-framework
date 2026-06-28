---@type lib.callback
local callback = require "lib.callback"

local M = {}

M.SETUP_REACTIVE_FIELDS = callback.api({
    name = "ui.animation.cooldown.SetupReactiveFields",
})

M.SETUP_REACTIVE_LOGIC = callback.api({
    name = "ui.animation.cooldown.SetupReactiveLogic",
})

return M
