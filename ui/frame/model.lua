---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_MODEL(function(api)
    local args = api.options or {}
    args.model = args.model or nil
    args.type = args.type or "model"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_MODEL requires CREATE_OBJECT result")
    local ui = create_api.ui

    ui.factory.model.set(args.model)
    ui.model.on_change.add(function(model)
        if model == nil or model == "" then
            return
        end

        apis.SET_MODEL({ handle = ui.handle(), model = model })
    end)

    ui.play = function(animation, is_loop, speed)
        apis.PLAY_ANIMATION({
            handle = ui.handle(),
            animation = animation,
            is_loop = is_loop,
            speed = speed,
        })
    end

    api.ui = ui
end)

return true
