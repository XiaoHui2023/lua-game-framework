---@class framework.visual_effect.settings
---@field DEFAULT_SOCKET string 挂载单位时默认使用的插槽名
---@field DEFAULT_SCALE number 创建特效时默认使用的整体缩放
---@field DEFAULT_DURATION number 字段说明
---@field DEFAULT_ANGLE number 创建特效时默认使用的朝向角度
---@field DEFAULT_HEIGHT number 创建在坐标点上时默认使用的离地高度
local M = {
    DEFAULT_SOCKET = "origin",
    DEFAULT_SCALE = 1,
    DEFAULT_DURATION = -1,
    DEFAULT_ANGLE = 0,
    DEFAULT_HEIGHT = 0,
}

return M
