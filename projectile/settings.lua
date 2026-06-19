---@class framework.projectile.settings
---@field DEFAULT_NAME string 默认投射物名称
---@field DEFAULT_EFFECT any 默认特效资源
---@field DEFAULT_POSITION point 默认出生位置
---@field DEFAULT_FACING number 默认朝向
---@field DEFAULT_HEIGHT number 默认离地高度
---@field DEFAULT_SCALE number 默认缩放
---@field DEFAULT_ANIMATION_SPEED number 默认动画速度
---@field DEFAULT_VISIBLE boolean 默认可见性
---@field DEFAULT_COLLISION_RADIUS number 默认碰撞半径
---@field DEFAULT_DURATION number 默认持续时间
local M = {}

M.DEFAULT_NAME = "projectile"
M.DEFAULT_EFFECT = nil
M.DEFAULT_POSITION = { x = 0, y = 0 }
M.DEFAULT_FACING = 0
M.DEFAULT_HEIGHT = 0
M.DEFAULT_SCALE = 1
M.DEFAULT_ANIMATION_SPEED = 1
M.DEFAULT_VISIBLE = true
M.DEFAULT_COLLISION_RADIUS = 0
M.DEFAULT_DURATION = -1

return M
