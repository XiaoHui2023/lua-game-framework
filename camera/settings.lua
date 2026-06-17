---@class framework.camera.settings
---@field DEFAULT_FAR_DISTANCE number 镜头允许拉远到的默认最大距离
---@field DEFAULT_NEAR_DISTANCE number 镜头允许拉近到的默认最小距离
---@field DEFAULT_WHEEL_STEP number 鼠标滚轮每次调整的默认距离步长
---@field DEFAULT_DISTANCE number 初始化时使用的默认镜头距离
---@field DEFAULT_WHEEL_DURATION number 鼠标滚轮调整镜头距离的默认过渡时间，单位秒
---@field DEFAULT_PITCH number 初始化时使用的默认俯仰角
---@field DEFAULT_ROLL number 初始化时使用的默认滚角
---@field DEFAULT_YAW number 初始化时使用的默认导航角
local M = {
    DEFAULT_FAR_DISTANCE = 3200,
    DEFAULT_NEAR_DISTANCE = 2500,
    DEFAULT_WHEEL_STEP = 100,
    DEFAULT_DISTANCE = 2850,
    DEFAULT_WHEEL_DURATION = 1,
    DEFAULT_PITCH = 65,
    DEFAULT_ROLL = 0,
    DEFAULT_YAW = 0,
}

return M
