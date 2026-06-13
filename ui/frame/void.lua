---@class models.ui
local g = require "..base"

---空的
---@param args? ui.options
---@param ... ui.options
---@return ui.void 返回对象
g.void = function(args,...)
    args = args or {}
    args = table.merge(args, ...)
    args.type = args.type or "void"

    ---@class ui.void : ui
    local o = g.create(args)

    ---@type hook.event<ui> 子元素布局变化事件
    o.on_children_layout_change = o.factory.event()

    return o
end