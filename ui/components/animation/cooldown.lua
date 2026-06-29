---@class framework.ui.components.animation.cooldown
---@field DEFAULT_COOLDOWN_READY_IMAGE any
---@field DEFAULT_COOLDOWN_PROGRESS_IMAGE any
---@field DEFAULT_COOLDOWN_TIME_OUT number
---@field DEFAULT_COOLDOWN_ALPHA_UPPER_THRESHOLD number
---@field DEFAULT_COOLDOWN_ALPHA_LOWER_THRESHOLD number
local M = {}
local factory = require("lib.reactive").factory
local settings = require "framework.ui.settings"
---@type framework.ui.components.animation.cooldown.api
local cooldown_apis = require "framework.ui.components.animation.cooldown_api"

require "framework.ui.components.animation.cooldown_impl"

---@class framework.ui.animation.cooldown.options
---@field ui framework.ui
---@field art_ready? any
---@field art_progress? any
---@field time_out? number
---@field alpha_upper_threshold? number
---@field alpha_lower_threshold? number
M.DEFAULT_COOLDOWN_READY_IMAGE = nil
M.DEFAULT_COOLDOWN_PROGRESS_IMAGE = nil
M.DEFAULT_COOLDOWN_TIME_OUT = 0.6
M.DEFAULT_COOLDOWN_ALPHA_UPPER_THRESHOLD = 0.7
M.DEFAULT_COOLDOWN_ALPHA_LOWER_THRESHOLD = 0.3

---@param args? framework.ui.animation.cooldown.options
---@return framework.ui.animation.cooldown
M.cooldown = function(args)
    args = args or {}
    args.art_ready = args.art_ready or M.DEFAULT_COOLDOWN_READY_IMAGE or settings.DEFAULT_COOLDOWN_READY_IMAGE
    args.art_progress = args.art_progress or M.DEFAULT_COOLDOWN_PROGRESS_IMAGE or settings.DEFAULT_COOLDOWN_PROGRESS_IMAGE
    args.time_out = args.time_out or M.DEFAULT_COOLDOWN_TIME_OUT
    args.alpha_upper_threshold = args.alpha_upper_threshold or M.DEFAULT_COOLDOWN_ALPHA_UPPER_THRESHOLD
    args.alpha_lower_threshold = args.alpha_lower_threshold or M.DEFAULT_COOLDOWN_ALPHA_LOWER_THRESHOLD

    ---@class framework.ui.animation.cooldown
    ---@field ui lib.reactive.ref 作用目标 UI
    ---@field progress lib.reactive.ref 冷却进度
    ---@field on_progress_change lib.reactive.event 冷却进度变化事件
    ---@field alpha_upper_threshold lib.reactive.ref 透明度上限阈值
    ---@field alpha_lower_threshold lib.reactive.ref 透明度下限阈值
    ---@field time_out lib.reactive.ref 冷却淡出时间
    ---@field on_cooldown_ready lib.reactive.event 冷却完成事件
    ---@field once_stop_fade_out lib.reactive.scope 停止淡出的单次释放域
    local o = factory()

    local fields = cooldown_apis.SETUP_REACTIVE_FIELDS:emit({
        cooldown = o,
        ui = args.ui,
        art_ready = args.art_ready,
        art_progress = args.art_progress,
        alpha_upper_threshold = args.alpha_upper_threshold,
        alpha_lower_threshold = args.alpha_lower_threshold,
        time_out = args.time_out,
    })
    cooldown_apis.SETUP_REACTIVE_LOGIC:emit({
        cooldown = o,
        ui_art_ready = fields.ui_art_ready,
        ui_art_progress = fields.ui_art_progress,
    })


    return o
end

return M
