---@class framework.ui.state
---@field HANDLE_TO_OBJECT table<framework.ui.handle, framework.ui> 运行时句柄到 UI 对象的映射
---@field event_registry? framework.ui.event.registry 共享鼠标事件注册表
local M = {}

---@type table<framework.ui.handle, framework.ui>
M.HANDLE_TO_OBJECT = {}

return M
