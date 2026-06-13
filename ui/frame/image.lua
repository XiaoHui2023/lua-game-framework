---@class models.ui
---@field DEFAULT_IMAGE any 默认图片
local g = require "..base"

-- image
g.DEFAULT_IMAGE = nil

---@param args ui.options
---@param ... ui.options
---@return ui.image 返回对象
g.image = function(args,...)
    args = table.merge(args, ...)
    args.image = args.image or g.DEFAULT_IMAGE
    args.type = args.type or "image"

    ---@class ui.image : ui
    local o = g.create(args)

    return o
end