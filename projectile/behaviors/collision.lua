---@type framework.projectile
local projectile = require "framework.projectile"

local function distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return (dx * dx + dy * dy) ^ 0.5
end

---@class projectile.options
---@field collision_radius? number 碰撞半径

---@param o projectile
---@param args projectile.options
return function(o, args)
    args.collision_radius = args.collision_radius or projectile.settings.DEFAULT_COLLISION_RADIUS

    o.factory.ref_field("collision_radius", args.collision_radius)

    ---@param position point
    ---@param radius? number 额外碰撞半径
    ---@return boolean
    o.is_colliding_position = function(position, radius)
        radius = radius or 0
        return distance(o.position(), position) <= o.collision_radius() + radius
    end

    ---@param unit unit
    ---@param radius? number 额外碰撞半径
    ---@return boolean
    o.is_colliding_unit = function(unit, radius)
        if unit == nil or unit.position == nil then
            return false
        end
        return o.is_colliding_position(unit.position(), radius)
    end
end
