---@type framework.player
local Player = require "..base"
---@type lib.addon
local addon = require "lib.addon"

---@class framework.player.behaviors: addon
local g = addon.register({
    name = "玩家选中单位行为",
    priority = addon.PRIORITY.MODELS,
})

-- 注册玩家选中单位行为
Player.attach_behavior(function(o)
    ---@class player
    o = o

    ---@type hook.event 玩家选中单位事件<unit>
    o.on_select_unit = o.factory.event()
end)

g.on_initialize.add(function()
    ---@type framework.event
    local event = require "framework.event"
    ---@class framework.unit
    local Unit = require "framework.unit"

    -- 绑定玩家选中单位事件
    event.ON_SELECT_UNIT(
        ---@param api event.SelectUnit
        function(api)
            api.player.on_select_unit(api.unit)
        end
    )
end)
