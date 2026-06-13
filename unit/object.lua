---@class models.unit
local g = require ".base"
---@type models.object
local object = require "models.object"
---@type utils.hook
local hook = require "utils.hook"

---@type hook.event 单位创建事件<unit>
g.ON_CREATE = hook.event()

---@class unit.options : object.options
---@field key? any 单位KEY
---@field player? player 玩家
---@field faction? faction 阵营

---新建单位
---@param args unit.options
---@param ... unit.options 其他参数
---@return unit 单位对象
g.create = function(args,...)
    args = table.merge(args, ...)
    -- 默认值
    args = args or {}
    args.key = args.key or g.DEFAULT_KEY
    args.player = args.player or g.DEFAULT_PLAYER
    args.faction = args.faction or g.DEFAULT_FACTION

    ---@class unit : object
    local o = object.create(args)
    -- 设置类
    o.set_class("unit")

    ---@type hook.set 物体ID
    o.key = o.factory.set(args.key)
    ---@type hook.set 玩家对象<player>
    o.player = o.factory.set(args.player)
    ---@type hook.set 阵营<faction>
    o.faction = o.factory.set(args.faction)
    ---@type hook.set 单位句柄
    o.handle = o.factory.set(g.new(args.key, args.position, args.player))

    -- 入库
    g.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function()
        g.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    -- 绑定删除
    o.delete.add(function()
        g.remove(o.handle())
    end)

    -- 注册行为
    require ".behaviors"(o, args)

    -- 触发单位创建事件
    g.ON_CREATE(o)

    return o
end


return g
