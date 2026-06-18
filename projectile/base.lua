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
---@field new fun(effect:any, 字段说明
---@field remove fun(handle:projectile.effect_handle)
---@field set_position fun(handle:projectile.effect_handle, position:point)
---@field set_facing fun(handle:projectile.effect_handle, facing:number)
---@field set_height fun(handle:projectile.effect_handle, height:number)
---@field set_scale fun(handle:projectile.effect_handle, 字段说明
---@field set_animation_speed fun(handle:projectile.effect_handle, speed:number)
---@field set_visible fun(handle:projectile.effect_handle, visible:boolean)
local M = {}
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

local function emit(api, values)
    local instance = api:new(values)
    instance:emit()
    return instance
end

M.new = function(effect, position, facing, scale, height, duration)
    local api = emit(apis.CREATE_EFFECT, {
        effect = effect,
        position = position,
        facing = facing,
        scale = scale,
        height = height,
        duration = duration,
    })
    assert(api.handle ~= nil, "framework.projectile.new requires runtime backend")
    return api.handle
end

M.remove = function(handle)
    emit(apis.REMOVE, { handle = handle })
end

M.set_position = function(handle, position)
    emit(apis.SET_POSITION, { handle = handle, position = position })
end

M.set_facing = function(handle, facing)
    emit(apis.SET_FACING, { handle = handle, facing = facing })
end

M.set_height = function(handle, height)
    emit(apis.SET_HEIGHT, { handle = handle, height = height })
end

M.set_scale = function(handle, scale_x, scale_y, scale_z)
    emit(apis.SET_SCALE, { handle = handle, scale_x = scale_x, scale_y = scale_y, scale_z = scale_z })
end

M.set_animation_speed = function(handle, speed)
    emit(apis.SET_ANIMATION_SPEED, { handle = handle, speed = speed })
end

M.set_visible = function(handle, visible)
    emit(apis.SET_VISIBLE, { handle = handle, visible = visible })
end

return M
