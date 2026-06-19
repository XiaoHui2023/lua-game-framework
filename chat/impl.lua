---@type framework.chat
local M = require "framework.chat"
---@type framework.chat.apis
local apis = require ".apis"

---@param api framework.chat.api.Input 聊天输入事件载荷
apis.ON_INPUT(function(api)
    M.send(api.player, api.content, api.channel)
end)
