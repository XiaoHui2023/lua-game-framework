---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.components.status.heart_health
local heart_health = require "framework.ui.components.status.heart_health"
---@type framework.ui.components.text.outlined_text
local outlined_text = require "framework.ui.components.text.outlined_text"

---@class framework.ui.components.status.hero_health
local M = {}

M.DEFAULT_TEXT_SIZE = { width = 72, height = 28 }
M.DEFAULT_TEXT_FONT_SIZE = 0.18
M.DEFAULT_TEXT_COLOR = { red = 255, green = 116, blue = 104 }
M.DEFAULT_TEXT_OUTLINE_COLOR = { red = 224, green = 70, blue = 84 }
M.DEFAULT_TEXT_OUTLINE_WIDTH = 1
M.DEFAULT_TEXT_VERTICAL_SPACE = -0.45
M.DEFAULT_DESCRIPTION_TEMPLATE = "{hero.name}\n生命：{hero.health} / {hero.max_health}"

---@param args? table
---@param ... table
---@return framework.ui.widget.heart_health
function M.create(args, ...)
    args = table.merge(args or {}, ...)
    args.name = args.name or "hero_health"
    args.focusable = args.focusable ~= false
    args.text = args.text or {}
    args.text.size = args.text.size or M.DEFAULT_TEXT_SIZE
    args.text.font_size = args.text.font_size or M.DEFAULT_TEXT_FONT_SIZE
    args.text.color = args.text.color or M.DEFAULT_TEXT_COLOR
    args.text.outline_color = args.text.outline_color or M.DEFAULT_TEXT_OUTLINE_COLOR
    args.text.outline_width = args.text.outline_width or M.DEFAULT_TEXT_OUTLINE_WIDTH
    args.text.vertical_space = args.text.vertical_space or M.DEFAULT_TEXT_VERTICAL_SPACE
    args.description_template = args.description_template or M.DEFAULT_DESCRIPTION_TEMPLATE

    local o = heart_health.create(args)
    o.description_template = args.description_template
    o.description_data = args.description_data

    o.value_text = outlined_text.create({
        name = "health_value",
        size = args.text.size,
        font_size = args.text.font_size,
        color = args.text.color,
        outline_color = args.text.outline_color,
        outline_width = args.text.outline_width,
        show = true,
    })
    o.factory.add_child(o.value_text.factory)
    o.value_text.anchor_bottom_outer(o, {
        vertical_space = args.text.vertical_space,
    })

    return o
end

return M
