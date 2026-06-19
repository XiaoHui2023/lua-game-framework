---@class framework.projectile
---@field settings framework.projectile.settings 投射物默认设置
---@field apis framework.projectile.apis 投射物 callback API 表
---@field HANDLE_TO_OBJECT table<projectile.effect_handle, projectile> 特效句柄到投射物对象的映射
local M = {}
package.loaded[...] = M
---@type framework.projectile.apis
local apis = require ".apis"
M.apis = apis
M.settings = require ".settings"

---@alias projectile.effect_handle Particle

---@type table<projectile.effect_handle, projectile>
M.HANDLE_TO_OBJECT = {}

require ".object"

return M
