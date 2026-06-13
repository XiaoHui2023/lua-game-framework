---@class models.unit
---@field DEFAULT_KEY any 默认出生单位KEY
---@field DEFAULT_MOVE_SPEED number 默认出生移速
---@field DEFAULT_BASE_ATTACK_SPEED number 默认出生基础攻击速度
---@field DEFAULT_ATTACK_SPEED number 默认出生攻击速度
---@field DEFAULT_ATTACK_RANGE number 默认出生攻击范围
---@field DEFAULT_TURN_SPEED number 默认出生转身速度
---@field DEFAULT_MODEL model 默认出生模型
---@field DEFAULT_PLAYER player 默认出生玩家
---@field DEFAULT_HEALTH number 默认出生血量
---@field DEFAULT_MAX_HEALTH number 默认出生最大血量
---@field DEFAULT_DAMAGE number 默认出生基础伤害
---@field DEFAULT_FACTION faction 默认出生阵营
---@field DEFAULT_COLOR_ENABLE boolean 默认出生颜色使能
---@field DEFAULT_COLOR color 默认出生颜色
---@field DEFAULT_OVERLAY_ENABLE boolean 默认出生覆盖使能
---@field DEFAULT_OVERLAY color 默认出生覆盖
---@field DEFAULT_OUTLINE_ENABLE boolean 默认出生描边使能
---@field DEFAULT_OUTLINE color 默认出生描边
---@field DEFAULT_ALPHA number 默认出生透明度
---@field DEFAULT_ANIMATION_SPEED number 默认出生动画速度
---@field DEFAULT_HEIGHT number 默认出生高度
---@field DEFAULT_SCALE number 默认出生缩放
---@field DEFAULT_SCALE_X number 默认出生X轴缩放
---@field DEFAULT_SCALE_Y number 默认出生Y轴缩放
---@field DEFAULT_SCALE_Z number 默认出生Z轴缩放
local g = require ".base"
---@type colorlib
local color = require "color"

g.DEFAULT_KEY = nil
g.DEFAULT_MOVE_SPEED = 225
g.DEFAULT_BASE_ATTACK_SPEED = 1
g.DEFAULT_ATTACK_SPEED = 1
g.DEFAULT_ATTACK_RANGE = 175
g.DEFAULT_TURN_SPEED = 10
g.DEFAULT_MODEL = nil
g.DEFAULT_PLAYER = nil
g.DEFAULT_HEALTH = 100
g.DEFAULT_MAX_HEALTH = 100
g.DEFAULT_DAMAGE = 1
g.DEFAULT_FACTION = nil
g.DEFAULT_COLOR_ENABLE = false
g.DEFAULT_COLOR = color.WHITE
g.DEFAULT_OVERLAY_ENABLE = false
g.DEFAULT_OVERLAY = color.WHITE
g.DEFAULT_OUTLINE_ENABLE = false
g.DEFAULT_OUTLINE = color.WHITE
g.DEFAULT_ALPHA = 255
g.DEFAULT_ANIMATION_SPEED = 1
g.DEFAULT_HEIGHT = 0
g.DEFAULT_SCALE = 1
g.DEFAULT_SCALE_X = 1
g.DEFAULT_SCALE_Y = 1
g.DEFAULT_SCALE_Z = 1

return g
