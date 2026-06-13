---@class models.ui
local g = require "..base"

---@param args ui.options
---@param ... ui.options
---@return ui.progress 返回对象
g.progress = function(args,...)
    args = table.merge(args, ...)
    args.image = args.image or g.DEFAULT_IMAGE
    args.type = args.type or "progress_ring"

    ---@class ui.progress : ui
    local o = g.create(args)
    
    return o
end

g.progress_ring = function(args)
    args.type = "progress_ring"
    return g.progress(args)
end

g.progress_bar = function(args)
    args.type = "progress_bar"
    return g.progress(args)
end