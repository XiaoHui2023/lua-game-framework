---@type models.game
local M = require ".base"
---@type models.player
local Player = require "models.player"

M.end_game = function()
    GameAPI.exit_game(Player.get_local().handle().handle)
end