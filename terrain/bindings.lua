---@class models.terrain
local M = require ".base"

M.set_texture = function(position,texture,range)
    range = range or M.UNIT_SIZE  --[[@as integer]]
    y3.game.modify_point_texture(y3.point.create(position.x,position.y),texture,range,math.floor(math.random_int(0,2)))
end

M.set_collision = function (position)
    y3.ground.set_collision(y3.point.create(position.x,position.y),true,true,true)
end

M.COLLISION_SIZE = 50

return M