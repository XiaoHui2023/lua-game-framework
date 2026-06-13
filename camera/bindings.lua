---@class models.camera
local g = require ".base"
---@type models.player
local Player = require "models.player"

g.limit_in_area = function(position,width,height)
	local area = y3.area.create_rectangle_area(y3.point(position.x,position.y), width,height)
	y3.camera.limit_in_rectangle_area(Player.get_local().handle(), area)
end

g.set_distance = function(distance,duration)
    duration = duration or 0
	y3.camera.set_distance(Player.get_local().handle(), distance,duration)
	g.distance = distance
end

g.set_yaw = function(value,duration)
	duration = duration or 0
	y3.camera.set_rotate(Player.get_local().handle(), 2, value, duration)
	g.yaw = value
end

g.set_pitch = function(value,duration)
	duration = duration or 0
	y3.camera.set_rotate(Player.get_local().handle(), 1, value, duration)
	g.pitch = value
end

g.set_roll = function(value,duration)
	duration = duration or 0
	y3.camera.set_rotate(Player.get_local().handle(), 3, value, duration)
	g.roll = value
end

g.set_user_control = function(enable)
	if enable then
		y3.camera.enable_camera_move(Player.get_local().handle())
	else
		y3.camera.disable_camera_move(Player.get_local().handle())
	end
end

g.set_position = function(position,duration)
	duration = duration or 0
	--y3.camera.look_at_point(Player.get_local().handle, y3.point(position.x,position.y), duration)
	y3.camera.linear_move_by_time(Player.get_local().handle(), y3.point(position.x,position.y), duration, y3.const.CameraMoveMode.SMOOTH)
end