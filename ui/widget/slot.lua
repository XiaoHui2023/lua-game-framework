---@class models.ui
---@field DEFAULT_SLOT_IMAGE_IMAGE any 默认插槽图片
---@field DEFAULT_SLOT_PROGRESS_IMAGE any 默认插槽进度图片
---@field DEFAULT_SLOT_BACKGROUND_IMAGE any 默认插槽背景图片
local g = require "..base"

---@class ui.slot.progress.options: ui.options
---@field enable? boolean 是否启用

---@class ui.slot.image.options: ui.options
---@field enable? boolean 是否启用

---@class ui.slot.background.options: ui.options
---@field enable? boolean 是否启用

---@class ui.slot.text.options: ui.options
---@field enable? boolean 是否启用

---@class ui.slot.options: ui.options
---@field progress? ui.slot.progress.options 进度选项
---@field image? ui.slot.image.options 图片选项
---@field background? ui.slot.background.options 背景选项
---@field text? ui.slot.text.options 文字选项

-- slot
g.DEFAULT_SLOT_IMAGE_IMAGE = nil
g.DEFAULT_SLOT_PROGRESS_IMAGE = nil
g.DEFAULT_SLOT_BACKGROUND_IMAGE = nil

-- 插槽
---@param args? ui.slot.options
---@param ... ui.slot.options
---@return ui.slot 返回对象
g.slot = function(args, ...)
    args = table.deep_merge(args, ...)
    args = args or {}
    args.progress = args.progress or {}
    args.image = args.image or {}
    args.background = args.background or {}
    args.text = args.text or {}
    args.image.enable = args.image.enable or false
    args.image.image = args.image.image or g.DEFAULT_SLOT_IMAGE_IMAGE
    args.image.size = args.image.size or 1
    args.background.enable = args.background.enable or false
    args.background.image = args.background.image or g.DEFAULT_SLOT_BACKGROUND_IMAGE
    args.background.size = args.background.size or 1
    args.progress.enable = args.progress.enable or false
    args.progress.image = args.progress.image or g.DEFAULT_SLOT_PROGRESS_IMAGE
    args.progress.size = args.progress.size or 1
    args.text.enable = args.text.enable or false
    args.text.size = args.text.size or 1

    ---@class ui.slot : ui.void
    ---@field progress? ui.progress 进度条
    ---@field image? ui.image 图片
    local o = g.void(args)

    -- 创建背景
    if args.background.enable then
        ---@type ui.image 背景子UI
        o.background = g.image(args.background, {
            name = "background",
            anchor = g.anchor({
                relative_ui = o,
            }),
            parent = o,
        })
    else
        o.background = nil
    end

    -- 创建进度条
    if args.progress.enable then
        ---@type ui.progress 进度条子UI
        o.progress = g.progress(args.progress, {
            name = "progress",
            anchor = g.anchor({
                relative_ui = o
            }),
            parent = o,
        })
    else
        o.progress = nil
    end

    -- 创建图片
    if args.image.enable then
        ---@type ui.image 图片子UI
        o.image = g.image(args.image, {
            name = "image",
            anchor = g.anchor({
                relative_ui = o,
            }),
            parent = o,
        })
    else
        o.image = nil
    end

    -- 创建文字
    if args.text.enable then
        ---@type ui.text 文字子UI
        o.text = g.text(args.text, {
            name = "text",
            anchor = g.anchor({
                relative_ui = o,
            }),
            parent = o,
        })
    else
        o.text = nil
    end

    -- 设置像素大小为最大的子控件
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

return g