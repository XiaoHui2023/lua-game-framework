---@class framework.chat
local M = require ".base"
---@type framework.player
local player_model = require "framework.player"

y3.game:event('玩家-发送消息', function(_, data)
    M.submit_input(player_model(data.player.id), data.str1)
end)

return M
