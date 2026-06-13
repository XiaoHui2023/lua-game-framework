---@class models.object
local g = require ".base"
local factory = require "models.factory"

---@class object.options: factory.options
---@field position point? 出生点

---@param args object.options
---@return object 新建物体
g.create = function(args)
    args.position = args.position or g.DEFAULT_POSITION

    ---@class object : factory
    local o = factory(args)
    -- 设置类
    o.set_class("object")

    ---@type hook.set 位置
    o.position = o.factory.set()

    ---@type hook.set 朝向
    o.facing = o.factory.set(0)

    return o
end

return g
