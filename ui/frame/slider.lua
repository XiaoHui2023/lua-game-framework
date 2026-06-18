---@class framework.ui
local M = require "..base"
---@type jass
local jass = require "jass"

---@class framework.ui
---@field SLIDER_VERTICAL 垂直滑动
---@field SLIDER_HORIZONTAL 水平滑动
M.SLIDER_VERTICAL = "SliderVertical"
M.SLIDER_HORIZONTAL = "SliderHorizontal"

---@class framework.ui.slider.options : ui.options
---@field direction string 滑动方向，默认水平
---@field percent number 百分比，默认1

---@param args framework.ui.slider.options
---@return ui.slider 滑条 UI 对象
M.slider = function(args)
    -- 默认值
    args.direction = args.direction or M.SLIDER_HORIZONTAL
    args.width = args.width or 0.139
    args.percent = args.percent or 1
    args.label = args.direction == M.SLIDER_VERTICAL and M.DEFAULT_SLIDER_Y_FRAME() or M.DEFAULT_SLIDER_X_FRAME()
    args.type = args.type or "slider"

    ---@class ui.slider : ui
    local o = M.create(args)

    ---@type lib.reactive.ref 滑动方向
    o.direction = o.factory.set(args.direction)

    ---@type lib.reactive.ref 滑块的百分比
    o.percent = o.factory.set(args.percent)

    ---@type reactive.event 百分比变化事件（new_percent,old_percent）
    o.on_percent_change = o.factory.event()

    -- 过滤处理滑块的百分比，如果是纵向滑，则颠倒 per : 百分比
    local function filter_percent(per)
        -- 得到类型
        local direction = o.direction()

        -- 纵向滑
        if direction == M.SLIDER_VERTICAL then
            per = 1 - per
        end

        return per
    end

    -- 初始百分比
    jass.dzapi.frame_set_value(o.handle(), o.percent())

    -- 注册定时器，响应百分比变化
    o.factory.interval(
        function()
            local old_percent = o.percent()
            local new_percent = jass.dzapi.frame_get_value(o.handle())

            -- 百分比变动，触发回调函数
            if old_percent ~= new_percent then
                -- 过滤百分比
                new_percent = filter_percent(new_percent)

                -- 设置百分比
                o.percent.set(new_percent)

                o.on_percent_change(new_percent, old_percent)
            end
        end
    )

    return o
end
