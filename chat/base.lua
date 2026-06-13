---@class models.chat
local g = {}
---@type utils.hook
local hook = require "utils.hook"
local list = require "list"

---@type hook.event 用户输入聊天事件（player,content）
g.ON_INPUT = hook.event()

---@type hook.event 聊天记录改变事件
g.ON_MESSAGE_CHANGE = hook.event()

---@class message
---@field player player 玩家
---@field content string 内容

---@type list<message> 聊天记录
g.MESSAGE_HISTORY = list()

-- 绑定输入事件。调用输入信息处理函数, 并添加到聊天记录中
g.ON_INPUT.add(function(player, str)
    ---@type message
    local msg = {
        player = player,
        content = str,
    }
    g.MESSAGE_HISTORY.append(msg)

    local list = g.MESSAGE_HISTORY
    local limit = g.MESSAGE_LIMIT

    -- 数目限制
    while list.count > limit do
        list.pop_front()
    end

    g.ON_MESSAGE_CHANGE(list)
end)

return g