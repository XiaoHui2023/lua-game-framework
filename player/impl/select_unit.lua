-- Register player object selection state and forward framework select events.
---@type framework.player.apis
local player_apis = require "..apis"
---@type framework.event.apis
local event = require "framework.event.apis"

---@param player player
local function ensure_select_unit_event(player)
    if player.on_select_unit ~= nil then
        return
    end

    ---@type reactive.event
    player.on_select_unit = player.factory.event()
end

player_apis.PLAYER_CREATED(function(api)
    ---@param api framework.player.api.PlayerCreated
    ensure_select_unit_event(api.player)
end)

event.ON_SELECT_UNIT(function(api)
    ---@param api event.SelectUnit
    local player = api.player
    if player == nil or player.on_select_unit == nil then
        return
    end

    player.on_select_unit(api.unit)
end)
