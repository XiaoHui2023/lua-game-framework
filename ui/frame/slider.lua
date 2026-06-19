---@class framework.ui
local M = require "framework.ui"
---@type jass
local jass = require "jass"

M.SLIDER_VERTICAL = "SliderVertical"
M.SLIDER_HORIZONTAL = "SliderHorizontal"

---@class framework.ui.slider.options : ui.options
---@field direction string
---@field percent number

---@param args? framework.ui.slider.options
---@return ui.slider
M.slider = function(args)
    args = args or {}
    args.direction = args.direction or M.SLIDER_HORIZONTAL
    args.width = args.width or 0.139
    args.percent = args.percent or 1
    if args.label == nil then
        if args.direction == M.SLIDER_VERTICAL and M.DEFAULT_SLIDER_Y_FRAME then
            args.label = M.DEFAULT_SLIDER_Y_FRAME()
        elseif M.DEFAULT_SLIDER_X_FRAME then
            args.label = M.DEFAULT_SLIDER_X_FRAME()
        end
    end
    args.type = args.type or "slider"

    ---@class ui.slider : ui
    local o = M.create(args)

    o.direction = o.factory.set(args.direction)
    o.percent = o.factory.set(args.percent)
    o.on_percent_change = o.factory.event()

    local function filter_percent(percent)
        if o.direction() == M.SLIDER_VERTICAL then
            return 1 - percent
        end
        return percent
    end

    jass.dzapi.frame_set_value(o.handle(), o.percent())

    o.factory.interval(function()
        local old_percent = o.percent()
        local new_percent = filter_percent(jass.dzapi.frame_get_value(o.handle()))
        if old_percent ~= new_percent then
            o.percent.set(new_percent)
            o.on_percent_change(new_percent, old_percent)
        end
    end)

    return o
end
