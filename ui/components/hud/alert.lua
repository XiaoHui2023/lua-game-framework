---@class framework.ui.components.hud.alert
local M = {}
---@type lib.colorlib
local color = require "lib.color"
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"
---@type framework.ui.components.animation.fade
local fade_prefab = require "framework.ui.components.animation.fade"

M.DEFAULT_COLOR = color.YELLOW
M.DEFAULT_TIME_STAY = 2.5
M.DEFAULT_TIME_OUT = 1
M.DEFAULT_FONT_SIZE = 0.2
M.DEFAULT_ANCHOR = nil
M.DEFAULT_SIZE = { width = 520, height = 64 }

---@class framework.ui.hud.alert.options
---@field time_stay? number
---@field time_out? number
---@field color? lib.color
---@field font_size? number
---@field anchor? framework.ui.anchor
---@field size? framework.ui.size_spec

---@param args? framework.ui.hud.alert.options
---@return framework.ui.hud.alert
M.create = function(args)
    args = args or {}
    args.time_stay = args.time_stay or M.DEFAULT_TIME_STAY
    args.time_out = args.time_out or M.DEFAULT_TIME_OUT
    args.color = args.color or M.DEFAULT_COLOR
    args.font_size = args.font_size or M.DEFAULT_FONT_SIZE
    args.anchor = args.anchor or M.DEFAULT_ANCHOR
    args.size = args.size or M.DEFAULT_SIZE

    local text_api = ui_apis.CREATE_TEXT({
        options = {
            font_size = args.font_size,
            show = false,
            anchor = args.anchor,
            align = "center",
            size = args.size,
            name = "alert_bar",
        },
    })
    ---@class framework.ui.hud.alert : framework.ui.text
    local o = text_api.ui

    o.factory.ref_field("color", args.color)

    o.fade = fade_prefab.create({
        ui = o,
        time_stay = args.time_stay,
        time_out = args.time_out,
    })

    o.text.wrap_set(function(content)
        return color.render(o.color(), content)
    end)

    o.text.on_change.add(function()
        o.fade()
    end)

    return o
end

return M
