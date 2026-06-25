---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param options framework.ui.anchor 锚点配置
---@return framework.ui.anchor anchor 标准化后的锚点配置
local function create_anchor(options)
    local api = apis.CREATE_ANCHOR({
        anchor = options,
    })
    assert(api.anchor ~= nil, "framework.ui.slot requires CREATE_ANCHOR result")
    return api.anchor
end

---@class framework.ui.slot.progress.options: framework.ui.object_config
---@field enable? boolean 是否创建进度子控件
---@field image? any 进度图片资源
---@field show? boolean 进度子控件初始可见性

---@class framework.ui.slot.image.options: framework.ui.object_config
---@field enable? boolean 是否创建图标子控件
---@field image? any 图标图片资源
---@field show? boolean 图标子控件初始可见性

---@class framework.ui.slot.background.options: framework.ui.object_config
---@field enable? boolean 是否创建背景子控件
---@field image? any 背景图片资源
---@field show? boolean 背景子控件初始可见性

---@class framework.ui.slot.text.options: framework.ui.object_config
---@field enable? boolean 是否创建文本子控件
---@field text? string 文本内容
---@field show? boolean 文本子控件初始可见性

---@class framework.ui.slot.options: framework.ui.object_config
---@field progress? framework.ui.slot.progress.options 进度子控件配置
---@field image? framework.ui.slot.image.options 图标子控件配置
---@field background? framework.ui.slot.background.options 背景子控件配置
---@field text? framework.ui.slot.text.options 文本子控件配置

---@param api framework.ui.api.CreateSlot 槽位创建回调参数
apis.CREATE_SLOT(function(api)
    local args = table.deep_merge(api.options, api.options_extra)
    args = args or {}
    args.progress = args.progress or {}
    args.image = args.image or {}
    args.background = args.background or {}
    args.text = args.text or {}
    args.image.enable = args.image.enable or false
    args.image.image = args.image.image or settings.DEFAULT_SLOT_IMAGE_IMAGE
    args.image.size = args.image.size or 1
    args.background.enable = args.background.enable or false
    args.background.image = args.background.image or settings.DEFAULT_SLOT_BACKGROUND_IMAGE
    args.background.size = args.background.size or 1
    args.progress.enable = args.progress.enable or false
    args.progress.image = args.progress.image or settings.DEFAULT_SLOT_PROGRESS_IMAGE
    args.progress.size = args.progress.size or 1
    args.text.enable = args.text.enable or false
    args.text.size = args.text.size or 1
    args.background.show = (args.background.show == nil) and true or args.background.show
    args.progress.show = (args.progress.show == nil) and true or args.progress.show
    args.image.show = (args.image.show == nil) and true or args.image.show
    args.text.show = (args.text.show == nil) and true or args.text.show

    local void_api = apis.CREATE_VOID({ options = args })
    assert(void_api.ui ~= nil, "framework.ui.CREATE_SLOT requires CREATE_VOID result")
    ---@type framework.ui.slot
    local o = void_api.ui
    o.is_content_sized = true

    if args.background.enable then
        ---@type framework.ui.api.CreateImage
        local image_api = apis.CREATE_IMAGE({
            options = table.merge(args.background, {
                name = "background",
                anchor = create_anchor({
                    relative_ui = o,
                }),
                parent = o,
            }),
        })
        o.background = image_api.ui
    else
        o.background = nil
    end

    if args.progress.enable then
        ---@type framework.ui.api.CreateProgress
        local progress_api = apis.CREATE_PROGRESS({
            options = table.merge(args.progress, {
                name = "progress",
                anchor = create_anchor({
                    relative_ui = o,
                }),
                parent = o,
            }),
        })
        o.progress = progress_api.ui
    else
        o.progress = nil
    end

    if args.image.enable then
        ---@type framework.ui.api.CreateImage
        local image_api = apis.CREATE_IMAGE({
            options = table.merge(args.image, {
                name = "image",
                anchor = create_anchor({
                    relative_ui = o,
                }),
                parent = o,
            }),
        })
        o.image = image_api.ui
    else
        o.image = nil
    end

    if args.text.enable then
        ---@type framework.ui.api.CreateText
        local text_api = apis.CREATE_TEXT({
            options = table.merge(args.text, {
                name = "text",
                anchor = create_anchor({
                    relative_ui = o,
                }),
                parent = o,
            }),
        })
        o.text = text_api.ui
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
        if o.text then
            width,height = o.text.scaled_pixel_size()
            max_width = math.max(max_width, width)
            max_height = math.max(max_height, height)
        end
        return max_width, max_height
    end)

    api.ui = o
end)

return true
