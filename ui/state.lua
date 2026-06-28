require "framework.ui.types"

---@type framework.ui.state
local M = {}

---@type table<framework.ui.handle, framework.ui>
M.HANDLE_TO_OBJECT = {}

---@type framework.ui.event.registry
M.event_registry = {}

return M
