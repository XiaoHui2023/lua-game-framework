---@class framework.timer.apis
---@field CREATE lib.callback.api 创建底层循环定时器并写回取消函数
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class timer.api.Create
---@field interval number 间隔秒数
---@field func fun() 定时回调
---@field cancel fun()? 运行时写回的取消函数
M.CREATE = callback.api({ name = "timer.CREATE" })

return M
