require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"
---@type framework.ui.components.animation.cooldown.api
local apis = require "framework.ui.components.animation.cooldown_api"

local function create_anchor(options)
    local api = ui_apis.CREATE_ANCHOR({
        anchor = options,
    })
    assert(api.anchor ~= nil, "framework.ui.components.animation.cooldown requires CREATE_ANCHOR result")
    return api.anchor
end

local function create_overlay_image(ui, art)
    local size = ui.measured_size()

    local image_api = ui_apis.CREATE_IMAGE({ options = {
        image = art,
        alpha = 0,
        anchor = create_anchor {
            relative_ui = ui,
            point = "center",
            relative_point = "center",
            x = 0,
            y = 0,
        },
        size = {
            width = size.width,
            height = size.height,
        },
        parent = ui.factory,
        show = true,
    }})
    return image_api.ui
end

apis.SETUP_REACTIVE_FIELDS(function(api)
    ---@type framework.ui.animation.cooldown
    local cooldown = api.cooldown

    api.ui_art_ready = create_overlay_image(api.ui, api.art_ready)
    api.ui_art_progress = create_overlay_image(api.ui, api.art_progress)

    api.ui.measured_size.on_change.add(function(size)
        local size_spec = {
            width = size.width,
            height = size.height,
        }
        api.ui_art_ready.size_spec.set(size_spec)
        api.ui_art_progress.size_spec.set(size_spec)
    end)

    cooldown.factory.ref_field("ui", api.ui)
    cooldown.factory.ref_field("progress", -1)
    cooldown.factory.event_field("on_progress_change")
    cooldown.factory.ref_field("alpha_upper_threshold", api.alpha_upper_threshold)
    cooldown.factory.ref_field("alpha_lower_threshold", api.alpha_lower_threshold)
    cooldown.factory.ref_field("time_out", api.time_out)
    cooldown.factory.event_field("on_cooldown_ready")
    cooldown.factory.field("once_stop_fade_out").scope()

    cooldown.progress.on_change.add(function(new_value, old_value)
        assert(new_value ~= nil and type(new_value) == "number", "percent is not a number")
        if new_value < 0 then
            return
        end
        assert(new_value >= 0 and new_value <= 1, "percent :" .. new_value .. " is not in 0-1")

        cooldown.on_progress_change(new_value, old_value)
    end)
end)

apis.SETUP_REACTIVE_LOGIC(function(api)
    ---@type framework.ui.animation.cooldown
    local cooldown = api.cooldown
    local ui_art_ready = api.ui_art_ready
    local ui_art_progress = api.ui_art_progress

    cooldown.on_cooldown_ready.add(function()
        local time_out = cooldown.time_out()
        local alpha = 255
        local time_interval = cooldown.factory.timer.interval_time()
        local alpha_decrease = 255 / (time_out / time_interval)

        cooldown.once_stop_fade_out()

        ui_art_ready.alpha.set(alpha)
        ui_art_progress.alpha.set(0)

        cooldown.factory.interval(function()
            alpha = alpha - alpha_decrease
            ui_art_ready.alpha.set(alpha)

            if alpha <= 0 then
                cooldown.once_stop_fade_out()
            end
        end, cooldown.once_stop_fade_out)

        cooldown.once_stop_fade_out.add(function()
            ui_art_ready.alpha.set(0)
        end)
    end)

    cooldown.on_progress_change.add(function(new_value, old_value)
        old_value = old_value or -1

        local is_ready = new_value >= 1 and old_value < 1
        local is_stop_fade_out = new_value < 1 and old_value >= 1

        if is_ready then
            return cooldown.on_cooldown_ready()
        end

        if is_stop_fade_out then
            cooldown.once_stop_fade_out()
        end

        local alpha_upper_threshold = cooldown.alpha_upper_threshold()
        local alpha_lower_threshold = cooldown.alpha_lower_threshold()
        local alpha_range = alpha_upper_threshold - alpha_lower_threshold
        local product = alpha_range * (1 - new_value) + alpha_lower_threshold
        local alpha = 255 * product

        ui_art_progress.alpha.set(alpha)
    end)
end)

return true