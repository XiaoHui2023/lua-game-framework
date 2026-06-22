---@class framework.unit.settings
---@field DEFAULT_POSITION point 默认出生位置
---@field DEFAULT_FACING number 默认朝向角度
---@field DEFAULT_KEY any 默认单位资源标识
---@field DEFAULT_MOVE_SPEED number 默认移动速度
---@field DEFAULT_BASE_ATTACK_SPEED number 默认基础攻击速度
---@field DEFAULT_ATTACK_SPEED number 默认攻击速度倍率
---@field DEFAULT_ATTACK_RANGE number 默认攻击范围
---@field DEFAULT_TURN_SPEED number 默认转身速度
---@field DEFAULT_MODEL model 默认模型资源
---@field DEFAULT_PLAYER player 默认所属玩家
---@field DEFAULT_HEALTH number 默认当前生命值
---@field DEFAULT_MAX_HEALTH number 默认最大生命值
---@field DEFAULT_DAMAGE number 默认攻击伤害
---@field DEFAULT_FACTION faction 默认阵营
---@field DEFAULT_COLOR_ENABLE boolean 默认是否启用颜色
---@field DEFAULT_COLOR lib.color 默认颜色
---@field DEFAULT_OVERLAY_ENABLE boolean 默认是否启用覆盖色
---@field DEFAULT_OVERLAY lib.color 默认覆盖色
---@field DEFAULT_OUTLINE_ENABLE boolean 默认是否启用描边
---@field DEFAULT_OUTLINE lib.color 默认描边色
---@field DEFAULT_ALPHA number 默认透明度
---@field DEFAULT_ANIMATION_SPEED number 默认动画速度倍率
---@field DEFAULT_HEIGHT number 默认离地高度
---@field DEFAULT_SCALE number 默认整体缩放
---@field DEFAULT_SCALE_X number 默认 X 轴缩放
---@field DEFAULT_SCALE_Y number 默认 Y 轴缩放
---@field DEFAULT_SCALE_Z number 默认 Z 轴缩放
local M = {}
---@type lib.colorlib
local color = require "lib.color"

M.DEFAULT_POSITION = {x = 0, y = 0}
M.DEFAULT_FACING = 0
M.DEFAULT_KEY = nil
M.DEFAULT_MOVE_SPEED = 225
M.DEFAULT_BASE_ATTACK_SPEED = 1
M.DEFAULT_ATTACK_SPEED = 1
M.DEFAULT_ATTACK_RANGE = 175
M.DEFAULT_TURN_SPEED = 10
M.DEFAULT_MODEL = nil
M.DEFAULT_PLAYER = nil
M.DEFAULT_HEALTH = 100
M.DEFAULT_MAX_HEALTH = 100
M.DEFAULT_DAMAGE = 1
M.DEFAULT_FACTION = nil
M.DEFAULT_COLOR_ENABLE = false
M.DEFAULT_COLOR = color.WHITE
M.DEFAULT_OVERLAY_ENABLE = false
M.DEFAULT_OVERLAY = color.WHITE
M.DEFAULT_OUTLINE_ENABLE = false
M.DEFAULT_OUTLINE = color.WHITE
M.DEFAULT_ALPHA = 255
M.DEFAULT_ANIMATION_SPEED = 1
M.DEFAULT_HEIGHT = 0
M.DEFAULT_SCALE = 1
M.DEFAULT_SCALE_X = 1
M.DEFAULT_SCALE_Y = 1
M.DEFAULT_SCALE_Z = 1

return M
