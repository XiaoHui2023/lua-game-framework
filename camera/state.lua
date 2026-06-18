---@class framework.camera.state
---@field distance number 字段说明
---@field yaw number 字段说明
---@field pitch number 字段说明
---@field roll number 字段说明
---@field user_control_enabled boolean 字段说明
---@field user_control_lock_count integer 字段说明
local M = {
    distance = 0,
    yaw = 0,
    pitch = 0,
    roll = 0,
    user_control_enabled = true,
    user_control_lock_count = 0,
}

return M
