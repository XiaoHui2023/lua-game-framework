---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
---@field DEFAULT_IMAGE any 默认图片资源
local M = require "..base"

-- image
M.DEFAULT_IMAGE = nil

---@param args ui.options
---@param ... ui.options
---@return ui.image 图片 UI 对象
M.image = function(args,...)
    args = table.merge(args, ...)
    args.image = args.image or M.DEFAULT_IMAGE
    args.type = args.type or "image"

    ---@class ui.image : ui
    local o = M.create(args)

    return o
end
