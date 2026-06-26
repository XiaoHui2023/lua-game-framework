---@class framework.lighting
local M = require "framework.lighting"

local factory = require("lib.reactive").factory

---@class framework.lighting.params
---@field name string ?????
---@field start_point point ??
---@field end_point point ??
---@field start_height? number ????
---@field end_height? number ????

---@param k framework.lighting.params
---@return lighting lightning ?????
M.new = function(k)
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

    o.factory.ref_field("start_point", po)
    o.factory.ref_field("end_point", pt)
    o.factory.ref_field("start_height", ho)
    o.factory.ref_field("end_height", ht)

    return o
end

return M
