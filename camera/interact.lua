---@class models.camera
local g = require ".base"

-- 设置镜头距离
---@param distance number 镜头距离
---@param duration number 持续时间
local function set_distance(distance,duration)
    g.set_distance(distance,duration)
    g.DISTANCE.set(distance)
end

g.normal = function (duration)
    duration = duration or 0
    g.set_yaw(g.DEFAULT_YAW,duration)
    g.set_pitch(g.DEFAULT_PITCH,duration)
    g.set_roll(g.DEFAULT_ROLL,duration)
end

g.reset = function(duration)
    duration = duration or 0
    g.normal(duration)
    set_distance(g.DEFAULT_DISTANCE,duration)
end

-- 用户控制锁
g.USER_CONTROL.on_acquire.add(function()
    -- 禁用控制权
    g.set_user_control(false)
end)
g.USER_CONTROL.on_release.add(function()
    -- 启用控制权
    g.set_user_control(true)
end)

g.scroll = function(distance)
    local distance_max = g.DEFAULT_FAR_DISTANCE
    local distance_min = g.DEFAULT_NEAR_DISTANCE
    local duration = g.DEFAULT_WHEEL_DURATION
    
    -- 限制
    distance = (distance > distance_max and distance_max) or distance
    distance = (distance < distance_min and distance_min) or distance
    
    -- 应用
    set_distance(distance, duration)
end

g.scroll_up = function()
    g.scroll(g.DISTANCE()+g.DEFAULT_WHEEL_STEP)
end

g.scroll_down = function()
    g.scroll(g.DISTANCE()-g.DEFAULT_WHEEL_STEP)
end

return g