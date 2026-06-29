---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"

---@class framework.ui.components.text.outlined_text
local M = {}

M.DEFAULT_SIZE = { width = 80, height = 32 }
M.DEFAULT_FONT_SIZE = 0.18
M.DEFAULT_TEXT_COLOR = { red = 255, green = 255, blue = 255 }
M.DEFAULT_OUTLINE_COLOR = { red = 0, green = 0, blue = 0 }
M.DEFAULT_OUTLINE_WIDTH = 2

local function create_text(options)
    local api = ui_apis.CREATE_TEXT({ options = options })
    assert(api.ui ~= nil, "outlined_text requires CREATE_TEXT result")
    return api.ui
end

---@param args? table
---@param ... table
---@return framework.ui.text
function M.create(args, ...)
    args = require("lib.tablex").merge(args or {}, ...)
    args.name = args.name or "outlined_text"
    args.size = args.size or M.DEFAULT_SIZE
    args.text = args.text or ""
    args.font_size = args.font_size or M.DEFAULT_FONT_SIZE
    args.color = args.color or M.DEFAULT_TEXT_COLOR
    args.outline_color = args.outline_color or M.DEFAULT_OUTLINE_COLOR
    args.outline_width = args.outline_width or M.DEFAULT_OUTLINE_WIDTH

    local o = create_text({
        name = args.name,
        text = args.text,
        size = args.size,
        font_size = args.font_size,
        align = "center",
        color = args.color,
        outline = {
            enable = true,
            width = args.outline_width,
            color = args.outline_color,
        },
        show = args.show,
    })

    return o
end

return M
