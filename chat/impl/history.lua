-- 维护聊天历史：接收聊天输入，追加消息、裁剪长度，并广播消息列表变化。
---@type framework.chat
local g = require "..base"

g.ON_INPUT(function(api)
    ---@type message
    local msg = {
        player = api.player,
        content = api.content,
    }
    g.MESSAGE_HISTORY.append(msg)

    local list = g.MESSAGE_HISTORY
    local limit = g.MESSAGE_LIMIT

    while list.count > limit do
        list.pop_front()
    end

    g.ON_MESSAGE_CHANGE({ messages = list })
end)
