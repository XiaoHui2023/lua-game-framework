---@class framework.unit
---@field DEFAULT_POSITION point 默认出生点
---@field DEFAULT_FACING number 默认出生朝向
---@field DEFAULT_KEY any 字段说明
---@field DEFAULT_MOVE_SPEED number 字段说明
---@field DEFAULT_BASE_ATTACK_SPEED number 字段说明
---@field DEFAULT_ATTACK_SPEED number 字段说明
---@field DEFAULT_ATTACK_RANGE number 字段说明
---@field DEFAULT_TURN_SPEED number 字段说明
---@field DEFAULT_MODEL model 字段说明
---@field DEFAULT_PLAYER player 字段说明
---@field DEFAULT_HEALTH number 字段说明
---@field DEFAULT_MAX_HEALTH number 字段说明
---@field DEFAULT_DAMAGE number 字段说明
---@field DEFAULT_FACTION faction 字段说明
---@field DEFAULT_COLOR_ENABLE boolean 字段说明
---@field DEFAULT_COLOR color 字段说明
---@field DEFAULT_OVERLAY_ENABLE boolean 字段说明
---@field DEFAULT_OVERLAY color 字段说明
---@field DEFAULT_OUTLINE_ENABLE boolean 字段说明
---@field DEFAULT_OUTLINE color 字段说明
---@field DEFAULT_ALPHA number 字段说明
---@field DEFAULT_ANIMATION_SPEED number 字段说明
---@field DEFAULT_HEIGHT number 字段说明
---@field DEFAULT_SCALE number 字段说明
---@field DEFAULT_SCALE_X number 字段说明
---@field DEFAULT_SCALE_Y number 字段说明
---@field DEFAULT_SCALE_Z number 字段说明
local M = require "framework.unit"
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
