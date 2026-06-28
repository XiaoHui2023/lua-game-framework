local factory = require("lib.reactive").factory
---@type framework.ui.components.animation.fade.api
local fade_apis = require "framework.ui.components.animation.fade_api"

require "framework.ui.components.animation.fade_impl"

---@class framework.ui.components.animation.fade
---@field DEFAULT_TIME_STAY number
---@field DEFAULT_TIME_OUT number
local M = {}

M.DEFAULT_TIME_STAY = 1
M.DEFAULT_TIME_OUT = 1

---@class framework.ui.components.animation.fade.options
---@field time_stay? number
---@field time_out? number
---@field ui framework.ui
---@param args? framework.ui.components.animation.fade.options
---@return framework.ui.animation.fade
M.create = function(args)
    args = args or {}
    args.time_stay = args.time_stay or M.DEFAULT_TIME_STAY
    args.time_out = args.time_out or M.DEFAULT_TIME_OUT

    ---@class framework.ui.animation.fade
    ---@field ui lib.reactive.ref 作用目标 UI
    ---@field time_stay lib.reactive.ref 停留时间
    ---@field time_out lib.reactive.ref 淡出时间
    ---@field time_count lib.reactive.ref 当前计时
    ---@field on_run lib.reactive.event 淡出开始事件
    ---@field on_end lib.reactive.event 淡出结束事件
    ---@field run fun() 启动淡出
    local o = factory()

    fade_apis.SETUP_REACTIVE_FIELDS:emit({
        fade = o,
        ui = args.ui,
        time_stay = args.time_stay,
        time_out = args.time_out,
    })
    fade_apis.SETUP_REACTIVE_LOGIC:emit({
        fade = o,
    })


    return o
end

return M
