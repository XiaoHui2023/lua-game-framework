---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_EFFECT(function(api)
    local args = api.options or {}
    args.model = args.model or nil
    args.loop = args.loop or false
    args.size = args.size or { width = 120, height = 120 }
    args.type = args.type or "effect"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_EFFECT requires CREATE_OBJECT result")
    local ui = create_api.ui

    ui.factory.ref_field("model", args.model)
    ui.factory.ref_field("loop", args.loop)

    ui.play = function(speed)
        apis.PLAY_EFFECT({
            handle = ui.handle(),
            effect = ui.model(),
            is_loop = ui.loop(),
            speed = speed,
        })
    end

    api.ui = ui
end)

return true
