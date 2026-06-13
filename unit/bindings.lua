---@class models.unit
local g = require ".base"

---@alias unit.handle Unit

g.new = function(key, position, player)
    return y3.unit.create_unit(player.handle(), key, y3.point.create(position.x, position.y), math.random_angle())
end

g.kill = function(handle)
    handle:kill_by()
end

g.remove = function(handle)
    handle:remove()
end

g.revive = function(handle)
    handle:reborn()
end

g.command_stop = function(handle)
    handle:stop()
end

g.set_facing = function(handle, facing, duration)
    duration = duration or 0
    handle:set_facing(facing, duration)
end

g.get_facing = function(handle)
    return handle:get_facing()
end

g.set_height = function(handle, height, duration)
    duration = duration or 0
    handle:set_height(height, duration)
end

g.play_animation = function(handle, name, speed, start_time, end_time, loop, reset_on_end, transition_time)
    handle:play_animation(name, speed, start_time, end_time, loop, reset_on_end, transition_time, false)
end

g.set_animation_speed = function(handle, speed)
    handle:set_animation_speed(speed)
end

g.set_move_type = function(handle, move_type)
    if move_type == g.MOVE_TYPE.LAND then
        handle:set_move_channel_land()
    elseif move_type == g.MOVE_TYPE.AIR then
        handle:set_move_channel_air()
    end
end

g.replace_model = function(handle, key)
    handle:replace_model(key)
end

g.get_position = function(handle)
    local point = handle:get_point()
    return { x = point.x, y = point.y }
end

g.set_collision_radius = function(handle, radius)
    handle:set_collision_radius(radius)
    handle:set_shadow_radius(radius)
    -- 感觉是离散型的，调整不连贯，不好用
end

g.set_color = function(handle, enable, color, alpha)
    -- 默认值
    color = color or {}
    enable = (enable == nil and true) or enable
    local red = color.red or 255
    local green = color.green or 255
    local blue = color.blue or 255
    alpha = alpha or 255
    -- 归一化
    alpha = alpha / 255
    -- 限制
    alpha = (alpha > 1 and 1) or alpha
    alpha = (alpha < 0 and 0) or alpha
    red = (red > 255 and 255) or red
    red = (red < 0 and 0) or red
    green = (green > 255 and 255) or green
    green = (green < 0 and 0) or green
    blue = (blue > 255 and 255) or blue
    blue = (blue < 0 and 0) or blue
    y3.game.set_object_color(handle, red, green, blue, enable and 50 or 0, alpha)
end

g.set_outline = function(handle, enable, color)
    enable = (enable == nil and true) or enable
    color = color or {}
    local red = color.red or 255
    local green = color.green or 255
    local blue = color.blue or 255
    handle:set_outline_visible(enable)
    handle:set_outlined_color(red, green, blue)
end

g.set_overlay = function(handle, enable, color)
    enable = (enable == nil and true) or enable
    color = color or {}
    local red = color.red or 255
    local green = color.green or 255
    local blue = color.blue or 255
    y3.game.set_object_fresnel_visible(handle, enable)
    y3.game.set_object_fresnel(handle, red, green, blue)
end

g.set_turning_speed = function(handle, speed)
    handle:set_turning_speed(speed)
end

g.set_select_visible = function(handle, visible)
    handle:set_select_effect_visible(visible)
end

g.set_scale = function(handle, scale_x, scale_y, scale_z)
    scale_x = scale_x or 1
    scale_y = scale_y or scale_x or 1
    scale_z = scale_z or scale_x or 1
    handle:set_unit_scale(scale_x, scale_y, scale_z)
end

g.teleport = function(handle, position)
    handle:blink(y3.point.create(position.x, position.y))
end

g.set_position = function(handle, position)
    handle:set_point(y3.point.create(position.x, position.y), false)
end

g.enable_shadow = function(handle, enable)
    --y3.unit.api_set_disk_shadow_open(enable)
end

g.select = function(handle, player)
    player:select_unit(handle)
end

g.set_move_speed = function(handle, speed)
    handle:set_attr("ori_speed",speed)
    handle:set_base_speed(speed)
end

g.set_attack_speed = function(handle, speed)
    --handle:set_attr("attack_speed",speed)
    -- 有点问题，设置了之后A不出来
end

g.set_attack_interval = function(handle, interval)
    handle:set_attr("attack_interval",interval)
end

g.set_attack_range = function(handle, range)
    handle:set_attr("attack_range",range)
end

g.set_turn_speed = function(handle, speed)
    handle:set_turning_speed(speed)
end