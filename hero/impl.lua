---@type framework.hero
local hero = require "framework.hero"
---@type framework.player
local player_model = require "framework.player"
---@type framework.player.apis
local player_apis = player_model.apis

---@param player player
local function setup_player_hero(player)
    if player.hero ~= nil then
        return
    end

    player.factory.ref_field("hero", nil)
    player.factory.event_field("on_hero_changed")
end

player_apis.PLAYER_CREATED(function(payload)
    setup_player_hero(payload.player)
end)

if player_model.MAX_PLAYERS ~= nil then
    player_model.for_each(setup_player_hero)
end

hero.apis.SET_HERO(function(payload)
    setup_player_hero(payload.player)

    local old_hero = payload.player.hero()
    if old_hero == payload.hero then
        return
    end

    payload.old_hero = old_hero
    payload.player.hero.set(payload.hero)
    payload.player.on_hero_changed(payload.hero, old_hero)
    hero.apis.ON_HERO_CHANGED:emit(payload)
    if payload.player == player_model.get_local() and hero.LOCAL_HERO ~= nil then
        hero.LOCAL_HERO.mark_dirty()
    end
end)

return true
