-- 注册 action bar 槽位的快捷键按下、抬起和触发逻辑。
---@type framework.event.apis
local event_apis = require "framework.event.apis"
---@type framework.hotbar
local hotbar = require "framework.hotbar"

local function for_input_slot(input, callback)
    local bar = hotbar.get_for_player(input and input.player)
    if bar == nil then
        return
    end

    bar.slots().for_each(function(slot, context)
        if slot.key() == input.key then
            callback(bar, slot)
            context.stop()
        end
    end)
end

event_apis.ON_KEY_DOWN_SYNC(function(api)
    for_input_slot(api.input, function(_, slot)
        slot.on_key_down(api.input)
        slot.activate({
            player = api.input.player,
            input = api.input,
        })
    end)
end)

event_apis.ON_KEY_UP_SYNC(function(api)
    for_input_slot(api.input, function(_, slot)
        slot.on_key_up(api.input)
    end)
end)

return true
