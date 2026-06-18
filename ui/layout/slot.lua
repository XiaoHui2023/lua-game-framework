---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
---@field DEFAULT_SLOT_IMAGE_IMAGE any 默认槽位图标图片
---@field DEFAULT_SLOT_PROGRESS_IMAGE any 默认槽位进度图片
---@field DEFAULT_SLOT_BACKGROUND_IMAGE any 默认槽位背景图片
local M = require "..base"

---@class ui.slot.progress.options: ui.options
---@field enable? boolean 是否创建进度子控件

---@class ui.slot.image.options: ui.options
---@field enable? boolean 是否创建图标子控件

---@class ui.slot.background.options: ui.options
---@field enable? boolean 是否创建背景子控件

---@class ui.slot.text.options: ui.options
---@field enable? boolean 是否创建文本子控件

---@class ui.slot.options: ui.options
---@field progress? ui.slot.progress.options 进度子控件配置
---@field image? ui.slot.image.options 图标子控件配置
---@field background? ui.slot.background.options 背景子控件配置
---@field text? ui.slot.text.options 文本子控件配置

-- slot
M.DEFAULT_SLOT_IMAGE_IMAGE = nil
M.DEFAULT_SLOT_PROGRESS_IMAGE = nil
M.DEFAULT_SLOT_BACKGROUND_IMAGE = nil

---@param args? ui.slot.options 槽位配置
---@param ... ui.slot.options
---@return ui.slot 槽位 UI 对象
M.slot = function(args, ...)
    args = table.deep_merge(args, ...)
    args = args or {}
    args.progress = args.progress or {}
    args.image = args.image or {}
    args.background = args.background or {}
    args.text = args.text or {}
    args.image.enable = args.image.enable or false
    args.image.image = args.image.image or M.DEFAULT_SLOT_IMAGE_IMAGE
    args.image.size = args.image.size or 1
    args.background.enable = args.background.enable or false
    args.background.image = args.background.image or M.DEFAULT_SLOT_BACKGROUND_IMAGE
    args.background.size = args.background.size or 1
    args.progress.enable = args.progress.enable or false
    args.progress.image = args.progress.image or M.DEFAULT_SLOT_PROGRESS_IMAGE
    args.progress.size = args.progress.size or 1
    args.text.enable = args.text.enable or false
    args.text.size = args.text.size or 1

    ---@class ui.slot : ui.void
    ---@field progress? ui.progress 进度子控件
    ---@field image? ui.image 图标子控件
    local o = M.void(args)

    if args.background.enable then
        ---@type ui.image
        o.background = M.image(args.background, {
            name = "background",
            anchor = M.anchor({
                relative_ui = o,
            }),
            parent = o,
        })
    else
        o.background = nil
    end

    if args.progress.enable then
        ---@type ui.progress
        o.progress = M.progress(args.progress, {
            name = "progress",
            anchor = M.anchor({
                relative_ui = o
            }),
            parent = o,
        })
    else
        o.progress = nil
    end

    if args.image.enable then
        ---@type ui.image
        o.image = M.image(args.image, {
            name = "image",
            anchor = M.anchor({
                relative_ui = o,
            }),
            parent = o,
        })
    else
        o.image = nil
    end

    if args.text.enable then
        ---@type ui.text
        o.text = M.text(args.text, {
            name = "text",
            anchor = M.anchor({
                relative_ui = o,
            }),
            parent = o,
        })
    else
        o.text = nil
    end

    o.pixel_size.compute(function()
        ---@type number,number
        local max_width,max_height = 0,0
        ---@type number,number
        local width,height
        if o.progress then
            width,height = o.progress.scaled_pixel_size()
            max_width = math.max(max_width, width)
            max_height = math.max(max_height, height)
        end
        if o.image then
            width,height = o.image.scaled_pixel_size()
            max_width = math.max(max_width, width)
            max_height = math.max(max_height, height)
        end
        if o.background then
            width,height = o.background.scaled_pixel_size()
            max_width = math.max(max_width, width)
            max_height = math.max(max_height, height)
        end
        return max_width, max_height
    end)

    return o
end

return M
