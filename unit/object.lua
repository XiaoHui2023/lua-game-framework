---@type lib.tablex
local table = require "lib.tablex"
---@class framework.unit
local M = require "framework.unit"
local factory = require "lib.reactive".factory
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.unit.apis
local apis = require ".apis"

---@class unit.options: reactive.factory.options
---@field position
---@field facing
---@field key
---@field player
---@field faction

---@param args unit.options
---@param ... unit.options 参数说明
---@return unit 返回值
M.create = function(args,...)
    args = table.merge(args, ...)
    -- 姒涙
    args = args or {}
    args.key = args.key or M.DEFAULT_KEY
    args.player = args.player or M.DEFAULT_PLAYER
    args.faction = args.faction or M.DEFAULT_FACTION
    args.position = args.position or M.DEFAULT_POSITION
    args.facing = args.facing or M.DEFAULT_FACING

    ---@class unit: reactive.factory
    local o = factory(args)
    o.set_class("unit")

    ---@type reactive.set 浣嶇疆
    o.position = o.factory.set(args.position)
    ---@type reactive.set
    o.facing = o.factory.set(args.facing)
    ---@type reactive.set
    o.key = o.factory.set(args.key)
    ---@type reactive.set
    o.player = o.factory.set(args.player)
    ---@type reactive.set
    o.faction = o.factory.set(args.faction)
    ---@type reactive.set
    local create_api = apis.CREATE_HANDLE({
        key = args.key,
        position = args.position,
        player = args.player,
        facing = args.facing,
    })
    assert(create_api.handle ~= nil, "framework.unit.create requires runtime backend")
    o.handle = o.factory.set(create_api.handle)

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
