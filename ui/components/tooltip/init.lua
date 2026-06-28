local factory_model = require("lib.reactive").factory
---@type framework.ui.components.tooltip.api
local tooltip_apis = require "framework.ui.components.tooltip.apis"

require "framework.ui.components.tooltip.impl"

---@class framework.ui.components.tooltip
---@field DEFAULT_VERTICAL_SPACE number
---@field DEFAULT_HORIZONTAL_SPACE number
local M = {}

M.DEFAULT_VERTICAL_SPACE = 0
M.DEFAULT_HORIZONTAL_SPACE = 0

---@class framework.ui.components.tooltip.options
---@field holder_ui framework.ui
---@field text_ui framework.ui
---@field vertical_space? number
---@field horizontal_space? number
---@param args framework.ui.components.tooltip.options
---@return framework.ui.components.tooltip
M.create = function(args)
    args.vertical_space = args.vertical_space or M.DEFAULT_VERTICAL_SPACE
    args.horizontal_space = args.horizontal_space or M.DEFAULT_HORIZONTAL_SPACE

    ---@class framework.ui.components.tooltip
    ---@field holder_ui lib.reactive.ref 提示容器 UI
    ---@field text_ui lib.reactive.ref 提示文本 UI
    ---@field focus_ui lib.reactive.ref 当前聚焦 UI
    ---@field vertical_space lib.reactive.ref 垂直间距
    ---@field horizontal_space lib.reactive.ref 水平间距
    ---@field on_focus lib.reactive.event 聚焦事件
    ---@field on_blur lib.reactive.event 失焦事件
    local o = factory_model()

    tooltip_apis.SETUP_REACTIVE_FIELDS:emit({
        tooltip = o,
        holder_ui = args.holder_ui,
        text_ui = args.text_ui,
        vertical_space = args.vertical_space,
        horizontal_space = args.horizontal_space,
    })
    tooltip_apis.SETUP_REACTIVE_LOGIC:emit({
        tooltip = o,
        anchor = M.anchor,
    })

    return o
end

---@param holder_ui framework.ui
---@param focus_ui framework.ui
---@param vertical_space number
---@param horizontal_space number
M.anchor = function(holder_ui, focus_ui, vertical_space, horizontal_space)
    ---@type lib.point
    local focus_position = focus_ui.relative_position()
    local focus_x = focus_position.x
    local focus_y = focus_position.y
    local is_left = focus_x <= 0.5
    local is_right = focus_x > 0.5
    local is_top = focus_y >= 0.5
    local is_bottom = focus_y < 0.5

    if is_right and is_top then
        holder_ui.anchor_left_top_outer(focus_ui, {
            vertical_space = vertical_space,
            horizontal_space = horizontal_space,
        })
    elseif is_right and is_bottom then
        holder_ui.anchor_top_right_outer(focus_ui, {
            vertical_space = vertical_space,
            horizontal_space = horizontal_space,
        })
    elseif is_left and is_top then
        holder_ui.anchor_right_top_outer(focus_ui, {
            vertical_space = vertical_space,
            horizontal_space = horizontal_space,
        })
    elseif is_left and is_bottom then
        holder_ui.anchor_top_left_outer(focus_ui, {
            vertical_space = vertical_space,
            horizontal_space = horizontal_space,
        })
    end
end

return M
