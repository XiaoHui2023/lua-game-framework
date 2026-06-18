---@class framework.chat
---@field submit_input fun(player:player, content:string, channel?:string) 提交原始玩家输入
---@field send fun(player:player, content:string, channel?:string): message? 发送玩家聊天消息
---@field push fun(args:framework.chat.message.options): message? 追加一条聊天消息
---@field clear fun() 清空聊天历史并广播变更
---@field get_messages fun():list<message> 读取当前聊天历史列表
local g = {}
---@type fun(tb?: any[]): list
local list = require "lib.list"
---@type framework.chat.apis
local apis = require ".apis"

g.ON_INPUT = apis.ON_INPUT
g.ON_MESSAGE = apis.ON_MESSAGE
g.ON_MESSAGE_CHANGE = apis.ON_MESSAGE_CHANGE

---@class message
---@field player? player 发送消息的玩家；系统消息可为空
---@field content string 消息正文
---@field channel string 消息频道
---@field sender_name? string 非玩家消息的发送者名称
---@field sender_color? color 非玩家消息的发送者颜色

---@type list<message>
g.MESSAGE_HISTORY = list()

---@class framework.chat.message.options
---@field player? player 发送消息的玩家；系统消息可为空
---@field content string 消息正文
---@field channel? string 可选，消息频道；省略时为默认频道
---@field sender_name? string 可选，非玩家消息的发送者名称
---@field sender_color? color 可选，非玩家消息的发送者颜色

local function normalize_content(content)
    if content == nil then
        return ""
    end

    content = tostring(content)
    content = content:gsub("^%s+", ""):gsub("%s+$", "")

    return content
end

local function trim_history()
    local limit = g.MESSAGE_LIMIT
    if not limit or limit < 1 then
        return
    end

    while g.MESSAGE_HISTORY.count > limit do
        g.MESSAGE_HISTORY.pop_front()
    end
end

local function broadcast_change()
    g.ON_MESSAGE_CHANGE({ messages = g.MESSAGE_HISTORY })
end

---@param player player
---@param content string
---@param channel? string
g.submit_input = function(player, content, channel)
    g.ON_INPUT({
        player = player,
        content = content,
        channel = channel,
    })
end

---@param args framework.chat.message.options
---@return message?
g.push = function(args)
    args = args or {}

    local content = normalize_content(args.content)
    if content == "" then
        return nil
    end

    ---@type message
    local message = {
        player = args.player,
        content = content,
        channel = args.channel or "default",
        sender_name = args.sender_name,
        sender_color = args.sender_color,
    }

    g.MESSAGE_HISTORY.append(message)
    trim_history()

    g.ON_MESSAGE({ message = message })
    broadcast_change()

    return message
end

---@param player player
---@param content string
---@param channel? string
---@return message?
g.send = function(player, content, channel)
    return g.push({
        player = player,
        content = content,
        channel = channel,
    })
end

g.clear = function()
    while g.MESSAGE_HISTORY.count > 0 do
        g.MESSAGE_HISTORY.pop_front()
    end

    broadcast_change()
end

---@return list<message>
g.get_messages = function()
    return g.MESSAGE_HISTORY
end

return g
