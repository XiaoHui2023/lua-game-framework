---@type models.game
local g = require ".base"
---@type models.player
local Player = require "models.player"

g.end_game = function()
    GameAPI.exit_game(Player.get_local().handle().handle)
end