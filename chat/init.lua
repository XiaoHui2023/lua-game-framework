---@class framework.chat
---@field submit_input fun(player:player, content:string, channel?:string) 提交玩家聊天输入
---@field send fun(player:player, content:string, channel?:string) 发送玩家聊天消息
---@field push fun(args:framework.chat.message.options): message? 写入一条聊天消息
---@field clear fun() 清空聊天历史并广播变更
---@field get_messages fun():list<message> 读取当前聊天历史列表
local M = {}
package.loaded[...] = M
local list = require "lib.list"
---@type framework.chat.apis
local apis = require ".apis"

---@class message
---@field player? player 消息所属玩家
---@field content string 消息正文
---@field channel string 消息频道
---@field sender_name? string 显示用发送者名称
---@field sender_color? lib.color|table 显示用发送者颜色

---@type list<message>
M.MESSAGE_HISTORY = list()

---@class framework.chat.message.options
---@field player? player 消息所属玩家
---@field content string 消息正文
---@field channel? string 消息频道，省略时使用默认频道
---@field sender_name? string 显示用发送者名称
---@field sender_color? lib.color|table 显示用发送者颜色

local function normalize_content(content)
    if content == nil then
        return ""
    end

    content = tostring(content)
    content = content:gsub("^%s+", ""):gsub("%s+$", "")

    return content
end

local function trim_history()
    local limit = M.settings.MESSAGE_LIMIT
    if not limit or limit < 1 then
        return
    end

    while M.MESSAGE_HISTORY.count > limit do
        M.MESSAGE_HISTORY.pop_front()
    end
end

local function broadcast_change()
    apis.ON_MESSAGE_CHANGE({ messages = M.MESSAGE_HISTORY })
end

---@param player player
---@param content string
---@param channel? string 消息频道
M.submit_input = function(player, content, channel)
    apis.ON_INPUT({
        player = player,
        content = content,
        channel = channel,
    })
end

---@param args framework.chat.message.options
---@return message? message 成功写入的消息，空内容返回 nil
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

    apis.ON_MESSAGE({ message = message })
    broadcast_change()

    return message
end

---@param player player
---@param content string
---@param channel? string 消息频道，省略时使用默认频道
---@return message? message 成功写入的消息，空内容返回 nil
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

M.settings = require ".settings"
require ".impl"

return M
