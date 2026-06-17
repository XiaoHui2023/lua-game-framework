---@class framework.unit.apis
---@field ON_CREATE lib.callback.api 单位对象创建完成时触发
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class unit.Created
---@field unit unit 已创建的单位对象
M.ON_CREATE = callback.api({ name = "unit.ON_CREATE" })

return M
