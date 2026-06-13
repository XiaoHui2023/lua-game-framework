---@class models.lighting
local g = {}
local factory = require "models.factory"
---@type utils.hook
local hook = require "utils.hook"

---@class models.lighting.params
---@field name string 闪电链名字
---@field start_point? point 起点坐标
---@field end_point? point 终点坐标
---@field start_height? number 起点高度
---@field end_height? number 终点高度

---创建闪电链
---@param k models.lighting.params
---@return lighting 闪电链对象
g.new = function(k)
    -- 解包
    local name = k.name
    ---@type point 起点
    local po = k.start_point
    ---@type point 终点
    local pt = k.end_point
    local ho = k.start_height or 0
    local ht = k.end_height or 0

    ---@class lighting : factory
    local o = factory()

    ---@type number 闪电链句柄
    o.handle = nil

    ---@type hook.set 起点坐标
    o.start_point = o.factory.set(po)

    ---@type hook.set 终点坐标
    o.end_point = o.factory.set(pt)

    ---@type hook.set 起点高度
    o.start_height = o.factory.set(ho)

    ---@type hook.set 终点高度
    o.end_height = o.factory.set(ht)

    return o
end

return g