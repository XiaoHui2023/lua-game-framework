---@type framework.event
local event = require "framework.event"
---@type framework.ui
local ui = require "framework.ui.base"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

-- Bridges the framework input event into the UI mouse-move API.
event.ON_MOUSE_MOVE_ASYNC(function(api)
    local data = api.input
    apis.ON_MOUSE_MOVE_ASYNC({
        position = {
            x = data.window_pos.x / ui.get_window_width(),
            y = data.window_pos.y / ui.get_window_height(),
        },
    })
end)
