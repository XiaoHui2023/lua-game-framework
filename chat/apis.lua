---@class framework.chat.apis
---@field ON_INPUT lib.callback.api 玩家输入聊天内容时触发
---@field ON_MESSAGE lib.callback.api 聊天引擎追加单条消息时触发
---@field ON_MESSAGE_CHANGE lib.callback.api 聊天消息列表变化时触发，可重放最新消息列表
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class framework.chat.api.Input: lib.callback.instance
---@field player player 输入聊天内容的玩家
---@field content string 玩家输入的聊天文本
---@field channel? string 可选，消息频道；省略时为默认频道
---@type lib.callback.api
M.ON_INPUT = callback.api({ name = "chat.ON_INPUT" })

---@class framework.chat.api.Message: lib.callback.instance
---@field message message 新追加的聊天消息
---@type lib.callback.api
M.ON_MESSAGE = callback.api({ name = "chat.ON_MESSAGE" })

---@class framework.chat.api.MessageChange: lib.callback.instance
---@field messages list<message> 当前聊天消息列表
---@type lib.callback.api
M.ON_MESSAGE_CHANGE = callback.api({ name = "chat.ON_MESSAGE_CHANGE", replay = true })

return M
