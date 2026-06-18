---@type framework.chat
local M = require "..base"

---@param api framework.chat.api.Input
M.ON_INPUT(function(api)
    M.send(api.player, api.content, api.channel)
end)
