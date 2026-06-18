---@type lib.tablex
local table = require "lib.tablex"
---@class framework.unit
local g = require ".base"
local factory = require "lib.reactive".factory
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.unit.apis
local apis = require ".apis"

---@type reactive.event 閸楁洑缍呴崚娑樼紦娴滃
g.ON_CREATE = apis.ON_CREATE

---@class unit.options: reactive.factory.options
---@field position
---@field facing
---@field key
---@field player
---@field faction

---閺傛澘缂撻崡鏇氱秴
---@param args unit.options
---@param ... unit.options 鍏朵粬鍙傛暟
---@return unit 閸楁洑缍呯€电
g.create = function(args,...)
    args = table.merge(args, ...)
    -- 姒涙
    args = args or {}
    args.key = args.key or g.DEFAULT_KEY
    args.player = args.player or g.DEFAULT_PLAYER
    args.faction = args.faction or g.DEFAULT_FACTION
    args.position = args.position or g.DEFAULT_POSITION
    args.facing = args.facing or g.DEFAULT_FACING

    ---@class unit: reactive.factory
    local o = factory(args)
    o.set_class("unit")

    ---@type reactive.set 浣嶇疆
    o.position = o.factory.set(args.position)
    ---@type reactive.set 鏈濆悜
    o.facing = o.factory.set(args.facing)
    ---@type reactive.set 閻椻晙缍婭D
    o.key = o.factory.set(args.key)
    ---@type reactive.set 閻溾晛顔嶇€电
    o.player = o.factory.set(args.player)
    ---@type reactive.set 闂冧絻鎯€<faction>
    o.faction = o.factory.set(args.faction)
    ---@type reactive.set 閸楁洑缍呴崣銉︾労
    o.handle = o.factory.set(g.new(args.key, args.position, args.player, args.facing))

    -- 閸忋儱绨
    g.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function()
        g.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    -- 缂佹垵鐣鹃崚鐘绘珟
    o.delete.add(function()
        g.remove(o.handle())
    end)

    -- 濞夈劌鍞界悰灞艰礋
    require ".behaviors"(o, args)

    -- 瑙﹀彂鍗曚綅鍒涘缓浜嬩欢
    g.ON_CREATE({ unit = o })

    return o
end


return g
