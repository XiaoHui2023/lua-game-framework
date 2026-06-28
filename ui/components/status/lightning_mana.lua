---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui.components.status.lightning_mana
local M = {}
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"

M.DEFAULT_SIZE = { width = 72, height = 72 }
M.DEFAULT_PROGRESS_SIZE = { width = { percent = 1 }, height = { percent = 1 } }
M.DEFAULT_IMAGE_SIZE = { width = 43, height = 43 }
M.DEFAULT_PROGRESS_IMAGE = nil
M.DEFAULT_PROGRESS_ROTATION = 90
M.DEFAULT_PROGRESS_COLOR = {
    red = 255,
    green = 255,
    blue = 0,
}
M.DEFAULT_IMAGE = nil

---@class framework.ui.components.status.lightning_mana.progress_options: framework.ui.slot.progress.options
---@field image? any
---@field size? framework.ui.size_spec
---@field rotation? number
---@field color? lib.color|table

---@class framework.ui.components.status.lightning_mana.image_options: framework.ui.slot.image.options
---@field image? any
---@field size? framework.ui.size_spec

---@class framework.ui.components.status.lightning_mana.options: framework.ui.slot.options
---@field name? string
---@field size? framework.ui.size_spec
---@field progress? framework.ui.components.status.lightning_mana.progress_options
---@field image? framework.ui.components.status.lightning_mana.image_options

---@class framework.ui.widget.lightning_mana: framework.ui.slot
---@field progress framework.ui.slot.progress 闪电能量进度环
---@field image framework.ui.slot.image 闪电能量图标

---@param args framework.ui.components.status.lightning_mana.options?
---@param ... framework.ui.components.status.lightning_mana.options?
---@return framework.ui.widget.lightning_mana
M.create = function(args, ...)
    args = table.merge(args or {}, ...)
    args.name = args.name or "lightning_mana"
    args.size = args.size or M.DEFAULT_SIZE
    args.progress = args.progress or {}
    args.progress.image = args.progress.image or M.DEFAULT_PROGRESS_IMAGE
    args.progress.size = args.progress.size or M.DEFAULT_PROGRESS_SIZE
    args.progress.rotation = args.progress.rotation or M.DEFAULT_PROGRESS_ROTATION
    args.progress.color = args.progress.color or M.DEFAULT_PROGRESS_COLOR
    args.image = args.image or {}
    args.image.image = args.image.image or M.DEFAULT_IMAGE
    args.image.size = args.image.size or M.DEFAULT_IMAGE_SIZE

    local slot_api = ui_apis.CREATE_SLOT({
        options = args,
        options_extra = {
            progress = {
                name = "progress",
                enable = true,
                type = "progress_ring",
            },
            image = {
                name = "image",
                enable = true,
            },
        },
    })
    return slot_api.ui
end

return M
