---@class framework.ui
local g = require "..base"

---@class ui.button.options : ui.options

---@param args ui.button.options
---@return ui.button 返回对象
g.button = function(args)
    args.type = args.type or "button"

    ---@class ui.button : ui
    local o = g.create(args)

    return o
end