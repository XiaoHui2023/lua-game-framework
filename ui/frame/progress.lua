---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
local M = require "..base"

---@param args ui.options
---@param ... ui.options
---@return ui.progress 进度 UI 对象
M.progress = function(args,...)
    args = table.merge(args, ...)
    args.image = args.image or M.DEFAULT_IMAGE
    args.type = args.type or "progress_ring"

    ---@class ui.progress : ui
    local o = M.create(args)
    
    return o
end

M.progress_ring = function(args)
    args.type = "progress_ring"
    return M.progress(args)
end

M.progress_bar = function(args)
    args.type = "progress_bar"
    return M.progress(args)
end
