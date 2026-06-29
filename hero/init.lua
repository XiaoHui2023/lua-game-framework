---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.player
local player_model = require "framework.player"

---@class framework.hero
---@field apis framework.hero.apis
---@field LOCAL_HERO reactive.computed<unit?> 本地玩家当前控制的英雄
local M = {}
package.loaded[...] = M

M.apis = require ".apis"

---@param player player
---@param hero unit?
function M.set(player, hero)
    M.apis.SET_HERO:emit({
        player = player,
        hero = hero,
    })
end

---@param player? player
---@return unit?
function M.get(player)
    player = player or player_model.get_local()
    if player == nil or player.hero == nil then
        return nil
    end
    return player.hero()
end

M.LOCAL_HERO = reactive.computed(function()
    return M.get(player_model.get_local())
end)
M.LOCAL_HERO.auto_update()

require ".impl"

return M
