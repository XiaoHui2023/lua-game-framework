---@class models.terrain
local g = require ".base"

g.set_texture = function(position,texture,range)
    range = range or g.UNIT_SIZE  --[[@as integer]]
    y3.game.modify_point_texture(y3.point.create(position.x,position.y),texture,range,math.floor(math.random_int(0,2)))
end

g.set_collision = function (position)
    y3.ground.set_collision(y3.point.create(position.x,position.y),true,true,true)
end

g.COLLISION_SIZE = 50

return g