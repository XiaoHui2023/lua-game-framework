---@class framework.visual_effect
---@field apis framework.visual_effect.apis
---@field settings framework.visual_effect.settings
---@field new fun(key:any, target:visual_effect.target, options?:visual_effect.options):visual_effect.handle
---@field remove fun(handle:visual_effect.handle)
---@field set_position fun(handle:visual_effect.handle, position:point)
---@field set_height fun(handle:visual_effect.handle, height:number)
---@field set_rotation fun(handle:visual_effect.handle, x?:number, y?:number, z?:number)
---@field set_facing fun(handle:visual_effect.handle, facing:number)
---@field set_scale fun(handle:visual_effect.handle, scale_x?:number, scale_y?:number, scale_z?:number)
---@field set_color fun(handle:visual_effect.handle, color?:color, alpha?:number)
---@field set_animation_speed fun(handle:visual_effect.handle, speed:number)
---@field set_play_speed fun(handle:visual_effect.handle, speed:number)
---@field set_duration fun(handle:visual_effect.handle, duration:number)
---@field set_visible fun(handle:visual_effect.handle, visible:boolean)
local M = {
    ---@type framework.visual_effect.apis
    apis = require ".apis",
    ---@type framework.visual_effect.settings
    settings = require ".settings",
}

---@alias visual_effect.handle Particle
---@alias visual_effect.target point|unit.handle

---@class visual_effect.options
---@field socket? string 挂载到单位时使用的插槽名；省略时使用默认插槽
---@field angle? number 特效朝向角度；省略时为 0
---@field scale? number 创建特效时使用的整体缩放；省略时使用默认缩放
---@field duration? number 特效持续时间，单位为秒；省略时使用默认持续时间
---@field time? number 兼容旧参数，作用等同于 duration
---@field height? number 创建在坐标点上时使用的离地高度；省略时为 0
---@field immediate? boolean 是否立即创建并播放
---@field follow_rotation? number 挂载单位时是否跟随旋转
---@field follow_scale? boolean 挂载单位时是否跟随缩放
---@field detach? boolean 挂载单位时是否脱离目标

---@param api lib.callback.api
---@param values table
---@return lib.callback.instance
local function emit(api, values)
    local instance = api:new(values)
    instance:emit()
    return instance
end

---@param key any
---@param target visual_effect.target
---@param options? visual_effect.options
---@return visual_effect.handle
M.new = function(key, target, options)
    assert(target ~= nil, "visual_effect.new requires target")
    local api = emit(M.apis.CREATE, {
        key = key,
        target = target,
        options = options or {},
    })
    assert(api.handle ~= nil, "visual_effect.new requires runtime backend")
    return api.handle
end

---@param handle visual_effect.handle
M.remove = function(handle)
    emit(M.apis.REMOVE, { handle = handle })
end

---@param handle visual_effect.handle
---@param position point
M.set_position = function(handle, position)
    emit(M.apis.SET_POSITION, { handle = handle, position = position })
end

---@param handle visual_effect.handle
---@param height number
M.set_height = function(handle, height)
    emit(M.apis.SET_HEIGHT, { handle = handle, height = height })
end

---@param handle visual_effect.handle
---@param x? number
---@param y? number
---@param z? number
M.set_rotation = function(handle, x, y, z)
    emit(M.apis.SET_ROTATION, { handle = handle, x = x, y = y, z = z })
end

---@param handle visual_effect.handle
---@param facing number
M.set_facing = function(handle, facing)
    emit(M.apis.SET_FACING, { handle = handle, facing = facing })
end

---@param handle visual_effect.handle
---@param scale_x? number
---@param scale_y? number
---@param scale_z? number
M.set_scale = function(handle, scale_x, scale_y, scale_z)
    emit(M.apis.SET_SCALE, {
        handle = handle,
        scale_x = scale_x,
        scale_y = scale_y,
        scale_z = scale_z,
    })
end

---@param handle visual_effect.handle
---@param color? color
---@param alpha? number
M.set_color = function(handle, color, alpha)
    emit(M.apis.SET_COLOR, { handle = handle, color = color, alpha = alpha })
end

---@param handle visual_effect.handle
---@param speed number
M.set_animation_speed = function(handle, speed)
    emit(M.apis.SET_ANIMATION_SPEED, { handle = handle, speed = speed })
end

---@param handle visual_effect.handle
---@param speed number
M.set_play_speed = function(handle, speed)
    M.set_animation_speed(handle, speed)
end

---@param handle visual_effect.handle
---@param duration number
M.set_duration = function(handle, duration)
    emit(M.apis.SET_DURATION, { handle = handle, duration = duration })
end

---@param handle visual_effect.handle
---@param visible boolean
M.set_visible = function(handle, visible)
    emit(M.apis.SET_VISIBLE, { handle = handle, visible = visible })
end

require ".impl"

return M
