---@class models.camera
---@field DEFAULT_FAR_DISTANCE number 镜头最远距离
---@field DEFAULT_NEAR_DISTANCE number 镜头最近距离
---@field DEFAULT_WHEEL_STEP number 镜头单次滚轮递进距离
---@field DEFAULT_DISTANCE number 默认镜头距离
---@field DEFAULT_WHEEL_DURATION number 滚轮调整持续时间
---@field DEFAULT_PITCH number 默认镜头俯仰角（绕X轴的旋转角度）
---@field DEFAULT_ROLL number 默认镜头滚角（绕Z轴的旋转角度）
---@field DEFAULT_YAW number 默认镜头导航角（绕Y轴的旋转角度）
local g = require ".base"

g.DEFAULT_FAR_DISTANCE = 3200
g.DEFAULT_NEAR_DISTANCE = 2500
g.DEFAULT_WHEEL_STEP = 100
g.DEFAULT_DISTANCE = 2850
g.DEFAULT_WHEEL_DURATION = 1
g.DEFAULT_PITCH = 65
g.DEFAULT_ROLL = 0
g.DEFAULT_YAW = 0

return g