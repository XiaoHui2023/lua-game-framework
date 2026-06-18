---@class models.camera
---@field DEFAULT_FAR_DISTANCE number 字段说明
---@field DEFAULT_NEAR_DISTANCE number 字段说明
---@field DEFAULT_WHEEL_STEP number 字段说明
---@field DEFAULT_DISTANCE number 字段说明
---@field DEFAULT_WHEEL_DURATION number 字段说明
---@field DEFAULT_PITCH number 字段说明
---@field DEFAULT_ROLL number 字段说明
---@field DEFAULT_YAW number 字段说明
local M = require ".base"

M.DEFAULT_FAR_DISTANCE = 3200
M.DEFAULT_NEAR_DISTANCE = 2500
M.DEFAULT_WHEEL_STEP = 100
M.DEFAULT_DISTANCE = 2850
M.DEFAULT_WHEEL_DURATION = 1
M.DEFAULT_PITCH = 65
M.DEFAULT_ROLL = 0
M.DEFAULT_YAW = 0

return M
