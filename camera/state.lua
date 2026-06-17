---@class framework.camera.state
---@field distance number 当前镜头距离
---@field yaw number 当前镜头导航角
---@field pitch number 当前镜头俯仰角
---@field roll number 当前镜头滚角
---@field user_control_enabled boolean 玩家手动镜头控制是否启用
---@field user_control_lock_count integer 玩家手动镜头控制锁计数
local M = {
    distance = 0,
    yaw = 0,
    pitch = 0,
    roll = 0,
    user_control_enabled = true,
    user_control_lock_count = 0,
}

return M
