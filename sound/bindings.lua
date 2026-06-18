---@class models.sound
local M = require ".base"
---@type models.player
local Player = require "models.player"

---@alias sound.handle Sound

M.play = function(sound,is_loop)
    is_loop = is_loop or false
    return y3.sound.get_by_handle(GameAPI.play_sound_for_player(Player.get_local().handle().handle, sound, is_loop))
end

M.stop = function(handle)
    handle:stop(Player.get_local().handle(),true)
end

M.set_volume = function(handle, volume)
    assert(volume >= 0 and volume <= 100, "volume must be between 0 and 100")
    handle:set_volume(Player.get_local().handle(),math.floor(volume*100))
end