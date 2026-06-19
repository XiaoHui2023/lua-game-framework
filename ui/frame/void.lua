---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
local M = require "framework.ui"

---空节点
---@param args? ui.options 空节点创建参数
---@param ... ui.options
---@return ui.void 空节点 UI 对象
M.void = function(args,...)
    args = args or {}
    args = table.merge(args, ...)
    args.type = args.type or "void"

    ---@class ui.void : ui
    local o = M.create(args)

    ---@type reactive.event<ui>
    o.on_children_layout_change = o.factory.event()

    return o
end
