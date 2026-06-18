---@alias unit.handle Unit

---@class framework.unit
---@field new fun(key:any, 字段说明
---@field kill fun(handle:unit.handle) 杀死单位
---@field remove fun(handle:unit.handle) 删除单位
---@field revive fun(handle:unit.handle) 复活单位
---@field command_stop fun(handle:unit.handle) 执行停止命令
---@field command fun(handle:unit.handle) 执行命令
---@field set_facing fun(handle:unit.handle, 字段说明
---@field get_facing fun(handle:unit.handle):number 获取朝向
---@field set_height fun(handle:unit.handle, 字段说明
---@field play_animation fun(handle:unit.handle, 字段说明
---@field set_animation_speed fun(handle:unit.handle, speed:number) 设置动画速度
---@field set_move_type fun(handle:unit.handle, move_type:move_type) 设置移动类型
---@field replace_model fun(handle:unit.handle, key:any) 替换模型
---@field get_position fun(handle:unit.handle):point 获取位置
---@field set_collision_radius fun(handle:unit.handle, radius:number) 设置碰撞半径
---@field set_color fun(handle:unit.handle, enable:boolean, color:color, alpha:number) 设置颜色
---@field set_outline fun(handle:unit.handle, enable:boolean, color:color) 设置描边
---@field set_overlay fun(handle:unit.handle, enable:boolean, color:color) 设置覆盖
---@field teleport fun(handle:unit.handle,position:point) 传送（如果能到达）
---@field set_position fun(handle:unit.handle,position:point) 设置位置（不论是否能通行）
---@field enable_shadow fun(handle:unit.handle, enable:boolean) 设置阴影使能
---@field set_scale fun(handle:unit.handle, 字段说明
---@field set_animation_alternate fun(handle:unit.handle, name:string) 设置动画附加
---@field set_select_visible fun(handle:unit.handle, visible:boolean) 设置选择框可见性
---@field set_turning_speed fun(handle:unit.handle, speed:number) 设置转身速度
---@field select fun(handle:unit.handle,player:player.handle) 选中单位
---@field set_move_speed fun(handle:unit.handle, speed:number) 设置移动速度
---@field set_attack_speed fun(handle:unit.handle, speed:number) 设置攻击速度
---@field set_attack_interval fun(handle:unit.handle, 字段说明
---@field set_attack_range fun(handle:unit.handle, range:number) 设置攻击范围
---@field set_turn_speed fun(handle:unit.handle, speed:number) 设置转身速度
local M = {}
---@type framework.unit.apis
local apis = require ".apis"
M.apis = apis

---@type table<unit.handle, unit> 单位对象映射表
M.HANDLE_TO_OBJECT = {}

---@enum move_type
M.MOVE_TYPE = {
    LAND = "LAND", -- 地面
    AIR = "AIR", -- 空中
    NIL = "NIL", -- 无
}

local function emit(api, values)
    local instance = api:new(values)
    instance:emit()
    return instance
end

M.new = function(key, position, player, facing)
    local api = emit(apis.CREATE_HANDLE, { key = key, position = position, player = player, facing = facing })
    assert(api.handle ~= nil, "framework.unit.new requires runtime backend")
    return api.handle
end

M.kill = function(handle) emit(apis.KILL, { handle = handle }) end
M.remove = function(handle) emit(apis.REMOVE, { handle = handle }) end
M.revive = function(handle) emit(apis.REVIVE, { handle = handle }) end
M.command_stop = function(handle) emit(apis.COMMAND_STOP, { handle = handle }) end
M.set_facing = function(handle, facing, duration) emit(apis.SET_FACING, { handle = handle, facing = facing, duration = duration }) end
M.get_facing = function(handle)
    local api = emit(apis.GET_FACING, { handle = handle })
    return api.facing
end
M.set_height = function(handle, height, duration) emit(apis.SET_HEIGHT, { handle = handle, height = height, duration = duration }) end
M.play_animation = function(handle, name, speed, start_time, end_time, loop, reset_on_end, transition_time)
    emit(apis.PLAY_ANIMATION, { handle = handle, name = name, speed = speed, start_time = start_time, end_time = end_time, loop = loop, reset_on_end = reset_on_end, transition_time = transition_time })
end
M.set_animation_speed = function(handle, speed) emit(apis.SET_ANIMATION_SPEED, { handle = handle, speed = speed }) end
M.set_move_type = function(handle, move_type) emit(apis.SET_MOVE_TYPE, { handle = handle, move_type = move_type }) end
M.replace_model = function(handle, key) emit(apis.REPLACE_MODEL, { handle = handle, key = key }) end
M.get_position = function(handle)
    local api = emit(apis.GET_POSITION, { handle = handle })
    return api.position
end
M.set_collision_radius = function(handle, radius) emit(apis.SET_COLLISION_RADIUS, { handle = handle, radius = radius }) end
M.set_color = function(handle, enable, color, alpha) emit(apis.SET_COLOR, { handle = handle, enable = enable, color = color, alpha = alpha }) end
M.set_outline = function(handle, enable, color) emit(apis.SET_OUTLINE, { handle = handle, enable = enable, color = color }) end
M.set_overlay = function(handle, enable, color) emit(apis.SET_OVERLAY, { handle = handle, enable = enable, color = color }) end
M.set_turning_speed = function(handle, speed) emit(apis.SET_TURNING_SPEED, { handle = handle, speed = speed }) end
M.set_select_visible = function(handle, visible) emit(apis.SET_SELECT_VISIBLE, { handle = handle, visible = visible }) end
M.set_scale = function(handle, scale_x, scale_y, scale_z) emit(apis.SET_SCALE, { handle = handle, scale_x = scale_x, scale_y = scale_y, scale_z = scale_z }) end
M.teleport = function(handle, position) emit(apis.TELEPORT, { handle = handle, position = position }) end
M.set_position = function(handle, position) emit(apis.SET_POSITION, { handle = handle, position = position }) end
M.enable_shadow = function(handle, enable) emit(apis.ENABLE_SHADOW, { handle = handle, enable = enable }) end
M.select = function(handle, player) emit(apis.SELECT, { handle = handle, player = player }) end
M.set_move_speed = function(handle, speed) emit(apis.SET_MOVE_SPEED, { handle = handle, speed = speed }) end
M.set_attack_speed = function(handle, speed) emit(apis.SET_ATTACK_SPEED, { handle = handle, speed = speed }) end
M.set_attack_interval = function(handle, interval) emit(apis.SET_ATTACK_INTERVAL, { handle = handle, interval = interval }) end
M.set_attack_range = function(handle, range) emit(apis.SET_ATTACK_RANGE, { handle = handle, range = range }) end
M.set_turn_speed = function(handle, speed) emit(apis.SET_TURN_SPEED, { handle = handle, speed = speed }) end

return M
