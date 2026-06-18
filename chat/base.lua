---@class framework.chat
---@field submit_input fun(player:player, 字段说明
---@field send fun(player:player, 字段说明
---@field push fun(args:framework.chat.message.options): 字段说明
---@field clear fun() 清空聊天历史并广播变更
---@field get_messages fun():list<message> 读取当前聊天历史列表
local M = {}
---@type fun(tb?:
local list = require "lib.list"
---@type framework.chat.apis
local apis = require ".apis"

M.ON_INPUT = apis.ON_INPUT
M.ON_MESSAGE = apis.ON_MESSAGE
M.ON_MESSAGE_CHANGE = apis.ON_MESSAGE_CHANGE

---@class message
---@field player? player 字段说明
---@field content string 消息正文
---@field channel string 消息频道
---@field sender_name? string 字段说明
---@field sender_color? color 字段说明

---@type list<message>
M.MESSAGE_HISTORY = list()

---@class framework.chat.message.options
---@field player? player 字段说明
---@field content string 消息正文
---@field channel? string 字段说明
---@field sender_name? string 字段说明
---@field sender_color? color 字段说明

local function normalize_content(content)
    if content == nil then
        return ""
    end

    content = tostring(content)
    content = content:gsub("^%s+", ""):gsub("%s+$", "")

    return content
end

local function trim_history()
    local limit = M.MESSAGE_LIMIT
    if not limit or limit < 1 then
        return
    end

    while M.MESSAGE_HISTORY.count > limit do
        M.MESSAGE_HISTORY.pop_front()
    end
end

local function broadcast_change()
    M.ON_MESSAGE_CHANGE({ messages = M.MESSAGE_HISTORY })
end

---@param player player
---@param content string
---@param channel? string 参数说明
M.submit_input = function(player, content, channel)
    M.ON_INPUT({
        player = player,
        content = content,
        channel = channel,
    })
end

---@param args framework.chat.message.options
---@return message? 返回值
M.push = function(args)
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

    M.MESSAGE_HISTORY.append(message)
    trim_history()

    M.ON_MESSAGE({ message = message })
    broadcast_change()

    return message
end

---@param player player
---@param content string
---@param channel? string 参数说明
---@return message? 返回值
M.send = function(player, content, channel)
    return M.push({
        player = player,
        content = content,
        channel = channel,
    })
end

M.clear = function()
    while M.MESSAGE_HISTORY.count > 0 do
        M.MESSAGE_HISTORY.pop_front()
    end

    broadcast_change()
end

---@return list<message>
M.get_messages = function()
    return M.MESSAGE_HISTORY
end

return M
