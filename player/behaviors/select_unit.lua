---@type models.player
local Player = require "..base"
---@type models.mod
local mod = require "models.mod"

---@class models.player.behaviors:mod
local g = mod.register({
    name = "玩家选中单位行为",
    priority = mod.PRIORITY.MODELS,
})

-- 注册玩家选中单位行为
Player.attach_behavior(function(o)
    ---@class player
    o = o

    ---@type hook.event 玩家选中单位事件<unit>
    o.on_select_unit = o.factory.event()
end)

g.on_initialize.add(function()
    ---@type models.event
    local event = require "models.event"
    ---@class models.unit
    local Unit = require "models.unit"

    -- 绑定玩家选中单位事件
    event.ON_SELECT_UNIT.add(
        ---@param player player
        ---@param u unit
        function(player, u)
            player.on_select_unit(u)
        end
    )
end)