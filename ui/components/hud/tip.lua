---@class framework.ui.components.hud.tip
local M = {}
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"

M.DEFAULT_TIP_FONT_SIZE = 0.14
M.DEFAULT_TIP_BACKGROUND_IMAGE = nil
M.DEFAULT_TIP_HORIZONTAL_PADDING = 16
M.DEFAULT_TIP_VERTICAL_PADDING = 10

---@class framework.ui.hud.tip.options : framework.ui.slot.options
---@field horizontal_padding? number
---@field vertical_padding? number
---@field background? framework.ui.hud.tip.background_options
---@field text? framework.ui.hud.tip.text_options

---@class framework.ui.hud.tip.background_options: framework.ui.slot.background.options
---@field image? any

---@class framework.ui.hud.tip.text_options: framework.ui.slot.text.options
---@field font_size? number

---@param args? framework.ui.hud.tip.options
---@return framework.ui.hud.tip
M.create = function(args)
    args = args or {}
    args.background = args.background or {}
    args.background.image = args.background.image or M.DEFAULT_TIP_BACKGROUND_IMAGE
    args.background.size = args.background.size or { width = { percent = 1 }, height = { percent = 1 } }
    args.background.include_in_content = false
    args.text = args.text or {}
    args.text.font_size = args.text.font_size or M.DEFAULT_TIP_FONT_SIZE
    args.text.size = args.text.size or { width = "auto", height = "auto" }
    args.horizontal_padding = args.horizontal_padding or M.DEFAULT_TIP_HORIZONTAL_PADDING
    args.vertical_padding = args.vertical_padding or M.DEFAULT_TIP_VERTICAL_PADDING

    local slot_api = ui_apis.CREATE_SLOT({
        options = args,
        options_extra = {
            background = {
                name = "background",
                enable = true,
            },
            text = {
                name = "text",
                enable = true,
            },
            show = false,
        },
    })
    ---@class framework.ui.hud.tip : framework.ui.slot
    local o = slot_api.ui

    o.factory.ref_field("horizontal_padding", args.horizontal_padding)
    o.factory.ref_field("vertical_padding", args.vertical_padding)

    o.content_size.compute(function()
        local text_size = o.text.measured_size()
        return {
            width = text_size.width + o.horizontal_padding() * 2,
            height = text_size.height + o.vertical_padding() * 2,
        }
    end)

    return o
end

return M
