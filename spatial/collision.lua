local M = {}
local geometry = require "lib.mathx.geometry"

---@param a point
---@param b point
---@return number
function M.distance_squared(a, b)
    return geometry.distance_squared(a, b)
end

---@param a point
---@param b point
---@return number
function M.distance(a, b)
    return geometry.distance(a, b)
end

---@param object spatial.Body
---@param position point
---@param radius? number
---@return boolean
function M.object_intersects_circle(object, position, radius)
    radius = radius or 0
    return geometry.circles_intersect(object.get_position(), object.get_collision_radius(), position, radius)
end

---@param a spatial.Body
---@param b spatial.Body
---@return boolean
function M.objects_intersect(a, b)
    return geometry.circles_intersect(a.get_position(), a.get_collision_radius(), b.get_position(), b.get_collision_radius())
end

return M
