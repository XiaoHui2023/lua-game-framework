---@type framework.projectile
local projectile = require "..base"

local function distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return (dx * dx + dy * dy) ^ 0.5
end

---@class projectile.options
---@field collision_radius? number 字段说明

---@param o projectile
---@param args projectile.options
return function(o, args)
    args.collision_radius = args.collision_radius or projectile.DEFAULT_COLLISION_RADIUS

    o.collision_radius = o.factory.set(args.collision_radius)

    ---@param position point
    ---@param radius? number 参数说明
    ---@return boolean
    o.is_colliding_position = function(position, radius)
        radius = radius or 0
        return distance(o.position(), position) <= o.collision_radius() + radius
    end

    ---@param unit unit
    ---@param radius? number 参数说明
    ---@return boolean
    o.is_colliding_unit = function(unit, radius)
        if unit == nil or unit.position == nil then
            return false
        end
        return o.is_colliding_position(unit.position(), radius)
    end
end
