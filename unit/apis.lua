---@class framework.unit.apis
---@field ON_CREATE lib.callback.api 单位对象创建完成时触发
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class unit.Created
---@field unit unit 已创建的单位对象
M.ON_CREATE = callback.api({ name = "unit.ON_CREATE" })

M.CREATE_HANDLE = callback.api({ name = "unit.CREATE_HANDLE" })
M.KILL = callback.api({ name = "unit.KILL" })
M.REMOVE = callback.api({ name = "unit.REMOVE" })
M.REVIVE = callback.api({ name = "unit.REVIVE" })
M.COMMAND_STOP = callback.api({ name = "unit.COMMAND_STOP" })
M.SET_FACING = callback.api({ name = "unit.SET_FACING" })
M.GET_FACING = callback.api({ name = "unit.GET_FACING" })
M.SET_HEIGHT = callback.api({ name = "unit.SET_HEIGHT" })
M.PLAY_ANIMATION = callback.api({ name = "unit.PLAY_ANIMATION" })
M.SET_ANIMATION_SPEED = callback.api({ name = "unit.SET_ANIMATION_SPEED" })
M.SET_MOVE_TYPE = callback.api({ name = "unit.SET_MOVE_TYPE" })
M.REPLACE_MODEL = callback.api({ name = "unit.REPLACE_MODEL" })
M.GET_POSITION = callback.api({ name = "unit.GET_POSITION" })
M.SET_COLLISION_RADIUS = callback.api({ name = "unit.SET_COLLISION_RADIUS" })
M.SET_COLOR = callback.api({ name = "unit.SET_COLOR" })
M.SET_OUTLINE = callback.api({ name = "unit.SET_OUTLINE" })
M.SET_OVERLAY = callback.api({ name = "unit.SET_OVERLAY" })
M.SET_TURNING_SPEED = callback.api({ name = "unit.SET_TURNING_SPEED" })
M.SET_SELECT_VISIBLE = callback.api({ name = "unit.SET_SELECT_VISIBLE" })
M.SET_SCALE = callback.api({ name = "unit.SET_SCALE" })
M.TELEPORT = callback.api({ name = "unit.TELEPORT" })
M.SET_POSITION = callback.api({ name = "unit.SET_POSITION" })
M.ENABLE_SHADOW = callback.api({ name = "unit.ENABLE_SHADOW" })
M.SELECT = callback.api({ name = "unit.SELECT" })
M.SET_MOVE_SPEED = callback.api({ name = "unit.SET_MOVE_SPEED" })
M.SET_ATTACK_SPEED = callback.api({ name = "unit.SET_ATTACK_SPEED" })
M.SET_ATTACK_INTERVAL = callback.api({ name = "unit.SET_ATTACK_INTERVAL" })
M.SET_ATTACK_RANGE = callback.api({ name = "unit.SET_ATTACK_RANGE" })
M.SET_TURN_SPEED = callback.api({ name = "unit.SET_TURN_SPEED" })

return M
