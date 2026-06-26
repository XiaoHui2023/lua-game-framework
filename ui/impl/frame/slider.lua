---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type jass
local jass = require "jass"

local SLIDER_VERTICAL = "SliderVertical"
local SLIDER_HORIZONTAL = "SliderHorizontal"

apis.CREATE_SLIDER(function(api)
    local args = api.options or {}
    args.direction = args.direction or SLIDER_HORIZONTAL
    args.size = args.size or { width = 220, height = 24 }
    args.percent = args.percent or 1
    if args.label == nil then
        if args.direction == SLIDER_VERTICAL and settings.DEFAULT_SLIDER_Y_FRAME then
            args.label = settings.DEFAULT_SLIDER_Y_FRAME()
        elseif settings.DEFAULT_SLIDER_X_FRAME then
            args.label = settings.DEFAULT_SLIDER_X_FRAME()
        end
    end
    args.type = args.type or "slider"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_SLIDER requires CREATE_OBJECT result")
    local ui = create_api.ui

    ui.factory.ref_field("direction", args.direction)
    ui.factory.ref_field("percent", args.percent)
    ui.factory.event_field("on_percent_change")

    local function filter_percent(percent)
        if ui.direction() == SLIDER_VERTICAL then
            return 1 - percent
        end
        return percent
    end

    jass.dzapi.frame_set_value(ui.handle(), ui.percent())

    ui.factory.interval(function()
        local old_percent = ui.percent()
        local new_percent = filter_percent(jass.dzapi.frame_get_value(ui.handle()))
        if old_percent ~= new_percent then
            ui.percent.set(new_percent)
            ui.on_percent_change(new_percent, old_percent)
        end
    end)

    api.ui = ui
end)

return true
