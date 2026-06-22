require "framework.ui.types"
---@type framework.ui.apis
local apis = require ".apis"

---@class framework.ui
---@field apis framework.ui.apis UI callback API 表
---@field settings framework.ui.settings UI 默认配置
---@field HANDLE_TO_OBJECT table<framework.ui.handle, framework.ui> 控件句柄到框架 UI 对象的映射
---@field LAYER framework.ui.layer.registry UI 分层句柄注册表
local M = {}
package.loaded[...] = M

M.apis = apis
M.settings = require ".settings"

require ".state"
require ".layers"
require ".impl"
require ".object"
require ".frame"
require ".layout"

return M
