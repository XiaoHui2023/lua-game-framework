---@class framework.terrain
---@field apis framework.terrain.apis 地形 callback API 表
---@field COLLISION_SIZE number 碰撞大小（宽高）
local M = {}
package.loaded[...] = M

---@alias terrain.group any[] 地面纹理组
---@alias terrain.map table<point, any> 地面纹理映射表

---@class terrain.palette
---@field group terrain.group 地面纹理组
---@field blend_Count integer 混合数量

---@type framework.terrain.apis
local apis = require ".apis"

M.apis = apis

require ".settings"
require ".impl"
require ".painter"
require ".render"

return M
