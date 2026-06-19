---@class framework.ui
local M = require "framework.ui"

---@class ui.button.options : ui.options

---@param args ui.button.options
---@return ui.button 按钮 UI 对象
M.button = function(args)
    args.type = args.type or "button"

    ---@class ui.button : ui
    local o = M.create(args)

    return o
end
