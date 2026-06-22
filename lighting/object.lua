---@class framework.lighting
local M = require "framework.lighting"

local factory = require("lib.reactive").factory

---@class framework.lighting.params
---@field name string 闪电链名称
---@field start_point point 起点
---@field end_point point 终点
---@field start_height? number 起点高度
---@field end_height? number 终点高度

---@param k framework.lighting.params
---@return lighting lighting 闪电链对象
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

    ---@type reactive.set
    o.factory.start_point.set(po)

    ---@type reactive.set
    o.factory.end_point.set(pt)

    ---@type reactive.set 起点高度
    o.factory.start_height.set(ho)

    ---@type reactive.set 终点高度
    o.factory.end_height.set(ht)

    return o
end

return M
