-- 维护聊天历史：接收聊天输入，追加消息、裁剪长度，并广播消息列表变化。
---@type framework.chat
local g = require "..base"

---@param api framework.chat.api.Input
g.ON_INPUT(function(api)
    g.send(api.player, api.content, api.channel)
end)
