---@class models.chat
local g = require ".base"
---@type models.player
local Player = require "models.player"

y3.game:event('玩家-发送消息', function(_, data)
    g.ON_INPUT(Player(data.player.id), data.str1)
end)

return g