---@class framework.terrain
---@field set_texture fun(position:point,texture:any,range?:number) 字段说明
---@field set_collision fun(position:point) 设置碰撞
---@field COLLISION_SIZE number 碰撞大小（宽高）
local M = {}

---@alias terrain.group any[] 地面纹理组
---@alias terrain.map table<point, any> 地面纹理映射表

---@class terrain.palette
---@field group terrain.group 地面纹理组
---@field blend_Count integer 混合数量

---@type framework.terrain.apis
local apis = require ".apis"

M.apis = apis

M.set_texture = function(position, texture, range)
    apis.SET_TEXTURE({ position = position, texture = texture, range = range })
end

M.set_collision = function(position)
    apis.SET_COLLISION({ position = position })
end

return M
