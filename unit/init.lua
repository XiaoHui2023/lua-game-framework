---@alias unit.handle Unit

---@class framework.unit
---@field apis framework.unit.apis 单位 callback API 表
---@field HANDLE_TO_OBJECT table<unit.handle, unit> 单位句柄到框架单位对象的映射
local M = {}
package.loaded[...] = M
---@type framework.unit.apis
local apis = require ".apis"
M.apis = apis
M.settings = require ".settings"

---@type table<unit.handle, unit> 单位对象映射表
M.HANDLE_TO_OBJECT = {}

---@enum move_type
M.MOVE_TYPE = {
    LAND = "LAND", -- 地面
    AIR = "AIR", -- 空中
    NIL = "NIL", -- 无
}

require ".object"

return M
