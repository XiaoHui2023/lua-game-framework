---@class framework.unit.settings
---@field DEFAULT_POSITION point ?????
---@field DEFAULT_FACING number ??????
---@field DEFAULT_KEY any ????????
---@field DEFAULT_MOVE_SPEED number ??????
---@field DEFAULT_BASE_ATTACK_SPEED number ????????
---@field DEFAULT_ATTACK_SPEED number ????????
---@field DEFAULT_ATTACK_RANGE number ??????
---@field DEFAULT_TURN_SPEED number ??????
---@field DEFAULT_MODEL model ??????
---@field DEFAULT_PLAYER player ??????
---@field DEFAULT_HEALTH number ???????
---@field DEFAULT_MAX_HEALTH number ???????
---@field DEFAULT_DAMAGE number ??????
---@field DEFAULT_FACTION faction ????
---@field DEFAULT_COLOR_ENABLE boolean ????????
---@field DEFAULT_COLOR color ??????
---@field DEFAULT_OVERLAY_ENABLE boolean ?????????
---@field DEFAULT_OVERLAY color ?????
---@field DEFAULT_OUTLINE_ENABLE boolean ????????
---@field DEFAULT_OUTLINE color ??????
---@field DEFAULT_ALPHA number ?????
---@field DEFAULT_ANIMATION_SPEED number ??????
---@field DEFAULT_HEIGHT number ??????
---@field DEFAULT_SCALE number ??????
---@field DEFAULT_SCALE_X number ?? X ???
---@field DEFAULT_SCALE_Y number ?? Y ???
---@field DEFAULT_SCALE_Z number ?? Z ???
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
