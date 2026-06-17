---@class framework.lighting
local g = {}
local factory = require("lib.reactive").factory
---@type lib.reactive
local hook = require "lib.reactive"

---@class framework.lighting.params
---@field name string 闂數閾惧悕绉?---@field start_point? point 璧风偣鍧愭爣
---@field end_point? point 缁堢偣鍧愭爣
---@field start_height? number 璧风偣楂樺害
---@field end_height? number 缁堢偣楂樺害

---鍒涘缓闂數閾?
---@param k framework.lighting.params
---@return lighting 闂數閾惧璞?
g.new = function(k)
    -- 瑙ｅ寘
    local name = k.name
    ---@type point 璧风偣
    local po = k.start_point
    ---@type point 缁堢偣
    local pt = k.end_point
    local ho = k.start_height or 0
    local ht = k.end_height or 0

    ---@class lighting : hook.factory
    local o = factory()

    ---@type number 闂數閾惧彞鏌?
    o.handle = nil

    ---@type hook.set 璧风偣鍧愭爣
    o.start_point = o.factory.set(po)

    ---@type hook.set 缁堢偣鍧愭爣
    o.end_point = o.factory.set(pt)

    ---@type hook.set 璧风偣楂樺害
    o.start_height = o.factory.set(ho)

    ---@type hook.set 缁堢偣楂樺害
    o.end_height = o.factory.set(ht)

    return o
end

return g
