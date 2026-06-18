---@class models.camera
local M = require ".base"

---@param distance number 参数说明
---@param duration number 参数说明
local function set_distance(distance,duration)
    M.set_distance(distance,duration)
    M.DISTANCE.set(distance)
end

M.normal = function (duration)
    duration = duration or 0
    M.set_yaw(M.DEFAULT_YAW,duration)
    M.set_pitch(M.DEFAULT_PITCH,duration)
    M.set_roll(M.DEFAULT_ROLL,duration)
end

M.reset = function(duration)
    duration = duration or 0
    M.normal(duration)
    set_distance(M.DEFAULT_DISTANCE,duration)
end

M.USER_CONTROL.on_acquire.add(function()
    -- 禁用控制权
    M.set_user_control(false)
end)
M.USER_CONTROL.on_release.add(function()
    -- 启用控制权
    M.set_user_control(true)
end)

M.scroll = function(distance)
    local distance_max = M.DEFAULT_FAR_DISTANCE
    local distance_min = M.DEFAULT_NEAR_DISTANCE
    local duration = M.DEFAULT_WHEEL_DURATION
    
    -- 限制
    distance = (distance > distance_max and distance_max) or distance
    distance = (distance < distance_min and distance_min) or distance
    
    -- 应用
    set_distance(distance, duration)
end

M.scroll_up = function()
    M.scroll(M.DISTANCE()+M.DEFAULT_WHEEL_STEP)
end

M.scroll_down = function()
    M.scroll(M.DISTANCE()-M.DEFAULT_WHEEL_STEP)
end

return M
