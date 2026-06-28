---@type lib.metatablex
local metatable = require "lib.metatablex"
---@type framework.ui.components.animation.fade.api
local apis = require "framework.ui.components.animation.fade_api"

apis.SETUP_REACTIVE_FIELDS(function(api)
    ---@type framework.ui.animation.fade
    local fade = api.fade

    fade.factory.ref_field("ui", api.ui)
    fade.factory.ref_field("time_stay", api.time_stay)
    fade.factory.ref_field("time_out", api.time_out)
    fade.factory.ref_field("time_count", 0)
    fade.factory.event_field("on_run")
    fade.factory.event_field("on_end")
end)

apis.SETUP_REACTIVE_LOGIC(function(api)
    ---@type framework.ui.animation.fade
    local fade = api.fade

    fade.run = function()
        local time_count = fade.time_count()
        ---@type framework.ui
        local ui = fade.ui()
        local time_sum = fade.time_stay() + fade.time_out()

        fade.time_count.set(time_sum)

        if time_count > 0 then
            return
        end

        ui.alpha.set(255)
        fade.on_run()

        local time_interval = fade.factory.timer.interval_time()
        local time_out = fade.time_out()
        local once_end = fade.factory.create_once_event()

        once_end.add(function()
            fade.on_end()
        end)
        once_end.add(ui.weak_show.acquire())

        once_end.mount(fade.factory.timer(function()
            local current_time = fade.time_count() - time_interval
            local alpha
            local is_stay = current_time >= time_out

            if is_stay then
                alpha = 255
            else
                alpha = 255 * (current_time / time_out)
            end

            ui.alpha.set(alpha)
            fade.time_count.set(current_time)

            if current_time <= 0 then
                return once_end()
            end
        end))
    end

    metatable.callable(fade, fade.run)
end)

return true
