---@type lib.tablex
local table = require "lib.tablex"
---@class framework.unit
local g = require ".base"
local factory = require "lib.reactive".factory
---@type lib.reactive
local hook = require "lib.reactive"
---@type framework.unit.apis
local apis = require ".apis"

---@type hook.event 鍗曚綅鍒涘缓浜嬩欢<unit>
g.ON_CREATE = apis.ON_CREATE

---@class unit.options: hook.factory.options
---@field position? point 出生点
---@field facing? number 朝向
---@field key? any 鍗曚綅KEY
---@field player? player 鐜╁
---@field faction? faction 闃佃惀

---鏂板缓鍗曚綅
---@param args unit.options
---@param ... unit.options 鍏朵粬鍙傛暟
---@return unit 鍗曚綅瀵硅薄
g.create = function(args,...)
    args = table.merge(args, ...)
    -- 榛樿鍊?
    args = args or {}
    args.key = args.key or g.DEFAULT_KEY
    args.player = args.player or g.DEFAULT_PLAYER
    args.faction = args.faction or g.DEFAULT_FACTION
    args.position = args.position or g.DEFAULT_POSITION
    args.facing = args.facing or g.DEFAULT_FACING

    ---@class unit: hook.factory
    local o = factory(args)
    o.set_class("unit")

    ---@type hook.set 位置
    o.position = o.factory.set(args.position)
    ---@type hook.set 朝向
    o.facing = o.factory.set(args.facing)
    ---@type hook.set 鐗╀綋ID
    o.key = o.factory.set(args.key)
    ---@type hook.set 鐜╁瀵硅薄<player>
    o.player = o.factory.set(args.player)
    ---@type hook.set 闃佃惀<faction>
    o.faction = o.factory.set(args.faction)
    ---@type hook.set 鍗曚綅鍙ユ焺
    o.handle = o.factory.set(g.new(args.key, args.position, args.player, args.facing))

    -- 鍏ュ簱
    g.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function()
        g.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    -- 缁戝畾鍒犻櫎
    o.delete.add(function()
        g.remove(o.handle())
    end)

    -- 娉ㄥ唽琛屼负
    require ".behaviors"(o, args)

    -- 瑙﹀彂鍗曚綅鍒涘缓浜嬩欢
    g.ON_CREATE({ unit = o })

    return o
end


return g
