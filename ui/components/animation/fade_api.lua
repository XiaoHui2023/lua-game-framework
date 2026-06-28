---@type lib.callback
local callback = require "lib.callback"

local M = {}

M.SETUP_REACTIVE_FIELDS = callback.api({
    name = "ui.animation.fade.SetupReactiveFields",
})

M.SETUP_REACTIVE_LOGIC = callback.api({
    name = "ui.animation.fade.SetupReactiveLogic",
})

return M
