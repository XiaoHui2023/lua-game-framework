---@class framework.terrain
---@field set_texture fun(position:point,texture:any,range?:number) 设置地面纹理
---@field set_collision fun(position:point) 设置碰撞
---@field COLLISION_SIZE number 碰撞大小（宽高）
local g = {}

---@alias terrain.group any[] 地面纹理组
---@alias terrain.map table<point, any> 地面纹理映射表

---@class terrain.palette
---@field group terrain.group 地面纹理组
---@field blend_Count integer 混合数量

return g