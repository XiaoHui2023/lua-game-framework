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
---@field new fun(effect:any, position:point, facing?:number, scale?:number, height?:number, duration?:number): projectile.effect_handle
---@field remove fun(handle:projectile.effect_handle)
---@field set_position fun(handle:projectile.effect_handle, position:point)
---@field set_facing fun(handle:projectile.effect_handle, facing:number)
---@field set_height fun(handle:projectile.effect_handle, height:number)
---@field set_scale fun(handle:projectile.effect_handle, scale_x:number, scale_y?:number, scale_z?:number)
---@field set_animation_speed fun(handle:projectile.effect_handle, speed:number)
---@field set_visible fun(handle:projectile.effect_handle, visible:boolean)
local M = {}

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

return M
