---@class framework.sync.apis
---@field SEND lib.callback.api 发送同步消息
---@field LISTEN lib.callback.api 监听同步消息
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class sync.api.Send
---@field head string 消息头
---@field data table 消息数据
M.SEND = callback.api({ name = "sync.SEND" })

---@class sync.api.Listen
---@field head string 消息头
---@field callback fun(player:player, data:table) 收到消息后的回调
M.LISTEN = callback.api({ name = "sync.LISTEN" })

return M
