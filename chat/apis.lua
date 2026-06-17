---@class framework.chat.apis
---@field ON_INPUT lib.callback.api 玩家输入聊天内容时触发
---@field ON_MESSAGE_CHANGE lib.callback.api 聊天消息列表变化时触发，可重放最新消息列表
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class chat.Input
---@field player player 输入聊天内容的玩家
---@field content string 玩家输入的聊天文本
M.ON_INPUT = callback.api({ name = "chat.ON_INPUT" })

---@class chat.MessageChange
---@field messages list<message> 当前聊天消息列表
M.ON_MESSAGE_CHANGE = callback.api({ name = "chat.ON_MESSAGE_CHANGE", replay = true })

return M
