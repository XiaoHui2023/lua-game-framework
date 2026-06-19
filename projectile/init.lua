---@class framework.projectile
---@field DEFAULT_NAME string
---@field DEFAULT_EFFECT any
---@field DEFAULT_POSITION point
---@field DEFAULT_FACING number
---@field DEFAULT_HEIGHT number
---@field DEFAULT_SCALE number
---@field DEFAULT_ANIMATION_SPEED number
---@field DEFAULT_VISIBLE boolean
---@field DEFAULT_COLLISION_RADIUS number
---@field DEFAULT_DURATION number
---@field apis framework.projectile.apis 投射物 callback API 表
---@field HANDLE_TO_OBJECT table<projectile.effect_handle, projectile> 特效句柄到投射物对象的映射
local M = {}
package.loaded[...] = M
---@type framework.projectile.apis
local apis = require ".apis"
M.apis = apis

---@alias projectile.effect_handle Particle

---@type table<projectile.effect_handle, projectile>
M.HANDLE_TO_OBJECT = {}

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

---@class framework.projectile
require ".settings"
require ".impl"
require ".object"

return M
