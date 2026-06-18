---@type lib.tablex
local table = require "lib.tablex"
---@class framework.unit
local M = require ".base"
local factory = require "lib.reactive".factory
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.unit.apis
local apis = require ".apis"

---@type reactive.event
M.ON_CREATE = apis.ON_CREATE

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
    o.handle = o.factory.set(M.new(args.key, args.position, args.player, args.facing))

    M.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function()
        M.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    o.delete.add(function()
        M.remove(o.handle())
    end)

    require ".behaviors"(o, args)

    M.ON_CREATE({ unit = o })

    return o
end


return M
