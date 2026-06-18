---@class framework.lighting
local M = {}
local factory = require("lib.reactive").factory
---@type lib.reactive
local reactive = require "lib.reactive"

---@class framework.lighting.params
---@field name string 字段说明
---@field end_point
---@field start_height
---@field end_height

---@param k framework.lighting.params
---@return lighting 返回值
M.new = function(k)
    local name = k.name
    ---@type point
    local po = k.start_point
    ---@type point
    local pt = k.end_point
    local ho = k.start_height or 0
    local ht = k.end_height or 0

    ---@class lighting : reactive.factory
    local o = factory()

    ---@type number
    o.handle = nil

    ---@type reactive.set
    o.start_point = o.factory.set(po)

    ---@type reactive.set
    o.end_point = o.factory.set(pt)

    ---@type reactive.set 璧风偣楂樺害
    o.start_height = o.factory.set(ho)

    ---@type reactive.set 缁堢偣楂樺害
    o.end_height = o.factory.set(ht)

    return o
end

return M
