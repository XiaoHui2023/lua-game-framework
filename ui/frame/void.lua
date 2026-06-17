---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
local g = require "..base"

---绌虹殑
---@param args? ui.options
---@param ... ui.options
---@return ui.void 杩斿洖瀵硅薄
g.void = function(args,...)
    args = args or {}
    args = table.merge(args, ...)
    args.type = args.type or "void"

    ---@class ui.void : ui
    local o = g.create(args)

    ---@type hook.event<ui> 瀛愬厓绱犲竷灞€鍙樺寲浜嬩欢
    o.on_children_layout_change = o.factory.event()

    return o
end