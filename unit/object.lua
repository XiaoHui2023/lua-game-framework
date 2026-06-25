---@type lib.tablex
local table = require "lib.tablex"
---@class framework.unit
local M = require "framework.unit"
local factory = require "lib.reactive".factory
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.unit.apis
local apis = require ".apis"

---@class unit.options: lib.reactive.factory.options
---@field position? point 初始位置
---@field facing? number 初始朝向
---@field key? py.UnitKey 单位类型 key
---@field player? player 所属玩家
---@field faction? faction 所属阵营

---@param args unit.options
---@param ... unit.options 后续配置会合并到首个配置表
---@return unit unit 创建出的单位对象
M.create = function(args,...)
    args = table.merge(args, ...)
    -- 合并默认配置
    args = args or {}
    args.key = args.key or M.settings.DEFAULT_KEY
    args.player = args.player or M.settings.DEFAULT_PLAYER
    args.faction = args.faction or M.settings.DEFAULT_FACTION
    args.position = args.position or M.settings.DEFAULT_POSITION
    args.facing = args.facing or M.settings.DEFAULT_FACING

    ---@class unit: reactive.factory
    local o = factory(args)
    o.factory.set_class("unit")

    ---@type reactive.set 位置
    o.factory.position.set(args.position)
    ---@type reactive.set
    o.factory.facing.set(args.facing)
    ---@type reactive.set
    o.factory.key.set(args.key)
    ---@type reactive.set
    o.factory.player.set(args.player)
    ---@type reactive.set
    o.factory.faction.set(args.faction)
    ---@type reactive.set
    local create_api = apis.CREATE_HANDLE({
        key = args.key,
        position = args.position,
        player = args.player,
        facing = args.facing,
    })
    assert(create_api.handle ~= nil, "framework.unit.create requires runtime backend")
    o.factory.handle.set(create_api.handle)

    M.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function()
        M.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    o.delete.add(function()
        apis.REMOVE({ handle = o.handle() })
    end)

    require ".behaviors"(o, args)

    apis.ON_CREATE({ unit = o })

    return o
end


return M
