---@class framework.lighting
local g = {}
local factory = require("lib.reactive").factory
---@type lib.reactive
local reactive = require "lib.reactive"

---@class framework.lighting.params
---@field name string 闂傤亞鏁搁柧鎯ф倳缁
---@field end_point
---@field start_height
---@field end_height

---閸掓稑缂撻梻顏嗘暩闁
---@param k framework.lighting.params
---@return lighting 闂傤亞鏁搁柧鎯ь嚠鐠
g.new = function(k)
    -- 鐟欙絽瀵
    local name = k.name
    ---@type point 鐠ч
    local po = k.start_point
    ---@type point 缂佸牏鍋
    local pt = k.end_point
    local ho = k.start_height or 0
    local ht = k.end_height or 0

    ---@class lighting : reactive.factory
    local o = factory()

    ---@type number 闂傤亞鏁搁柧鎯у綖閺
    o.handle = nil

    ---@type reactive.set 璧风偣鍧愭爣
    o.start_point = o.factory.set(po)

    ---@type reactive.set 缁堢偣鍧愭爣
    o.end_point = o.factory.set(pt)

    ---@type reactive.set 璧风偣楂樺害
    o.start_height = o.factory.set(ho)

    ---@type reactive.set 缁堢偣楂樺害
    o.end_height = o.factory.set(ht)

    return o
end

return g
