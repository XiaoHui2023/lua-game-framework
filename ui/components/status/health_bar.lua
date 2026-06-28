---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui.components.status.health_bar
local M = {}
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"

M.DEFAULT_SIZE = { width = 260, height = 24 }
M.DEFAULT_PROGRESS_SIZE = { width = { percent = 0.86 }, height = { percent = 0.62 } }
M.DEFAULT_BACKGROUND_SIZE = { width = { percent = 1 }, height = { percent = 1 } }
M.DEFAULT_PROGRESS_IMAGE = nil
M.DEFAULT_PROGRESS_TYPE = "progress_bar"
M.DEFAULT_BACKGROUND_COLOR = {
    red = 0,
    green = 0,
    blue = 0,
}
M.DEFAULT_BACKGROUND_IMAGE = nil

---@class framework.ui.components.status.health_bar.progress_options: framework.ui.slot.progress.options
---@field image? any
---@field type? string
---@field size? framework.ui.size_spec

---@class framework.ui.components.status.health_bar.background_options: framework.ui.slot.background.options
---@field color? lib.color|table
---@field image? any
---@field size? framework.ui.size_spec

---@class framework.ui.components.status.health_bar.options: framework.ui.slot.options
---@field name? string
---@field size? framework.ui.size_spec
---@field progress? framework.ui.components.status.health_bar.progress_options
---@field background? framework.ui.components.status.health_bar.background_options

---@class framework.ui.widget.health_bar: framework.ui.slot
---@field progress framework.ui.slot.progress 血条进度子控件
---@field background framework.ui.slot.background 血条背景子控件
---@field text framework.ui.slot.text 血条文本子控件

---@param args framework.ui.components.status.health_bar.options?
---@param ... framework.ui.components.status.health_bar.options?
---@return framework.ui.widget.health_bar
M.create = function(args, ...)
    args = table.merge(args or {}, ...)
    args.name = args.name or "health_bar"
    args.size = args.size or M.DEFAULT_SIZE
    args.progress = args.progress or {}
    args.progress.image = args.progress.image or M.DEFAULT_PROGRESS_IMAGE
    args.progress.type = args.progress.type or M.DEFAULT_PROGRESS_TYPE
    args.progress.size = args.progress.size or M.DEFAULT_PROGRESS_SIZE
    args.background = args.background or {}
    args.background.color = args.background.color or M.DEFAULT_BACKGROUND_COLOR
    args.background.image = args.background.image or M.DEFAULT_BACKGROUND_IMAGE
    args.background.size = args.background.size or M.DEFAULT_BACKGROUND_SIZE

    local slot_api = ui_apis.CREATE_SLOT({
        options = args,
        options_extra = {
            progress = {
                name = "progress",
                enable = true,
            },
            background = {
                name = "background",
                enable = true,
            },
            text = {
                name = "text",
                enable = true,
                size = { width = { percent = 1 }, height = { percent = 1 } },
            },
        },
    })
    return slot_api.ui
end

return M
