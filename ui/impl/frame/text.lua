---@type lib.stringx
local string = require "lib.stringx"
---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@class framework.ui.text.options: framework.ui.object_config
---@field text? string 初始显示文本
---@field font_size? number 字体大小比例
---@field font? any 字体资源

---@param api framework.ui.api.CreateText 文本创建回调参数
apis.CREATE_TEXT(function(api)
    local options_extra = api.options_extra
    local args = api.options
    args = args or {}
    args = table.merge(args, options_extra)
    args.text = args.text or ""
    args.font_size = args.font_size or settings.DEFAULT_TEXT_FONT_SIZE
    args.align = args.align or settings.DEFAULT_TEXT_ALIGN
    args.type = args.type or "text"
    args.font = args.font or settings.DEFAULT_TEXT_FONT
    args.size = args.size or 1
    args.size_mode = args.size_mode or "contain"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_TEXT requires CREATE_OBJECT result")
    ---@type framework.ui.text
    local o = create_api.ui

    ---@type lib.reactive.ref 字体资源
    o.factory.font.set(args.font)

    ---@type lib.reactive.ref
    o.factory.font_pixel_size.set(0)

    ---@type lib.reactive.ref 字体大小比例
    o.factory.font_size.set(args.font_size)

    ---@type lib.reactive.ref
    o.factory.text.set(args.text)

    ---@type lib.reactive.ref
    o.factory.align.set(args.align)
    o.align.on_change.add(function(align)
        apis.SET_TEXT_ALIGNMENT({ handle = o.handle(), pos = align })
    end)

    ---@type lib.reactive.ref
    o.factory.outline.set(args.outline)
    o.outline.on_change.add(function(outline)
        apis.SET_TEXT_OUTLINE({ handle = o.handle(), outline = outline })
    end)

    ---@type reactive.computed <framework.ui.text.render_result>
    local render_text_clamped = o.factory.computed(function()
        local pixel_width = o.total_scaled_pixel_size()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size(),pixel_width)

        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type reactive.computed <framework.ui.text.render_result>
    local render_text_unlimited = o.factory.computed(function()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size())
        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type reactive.computed
    o.factory.text_relative_size_clamped.computed(function()
        local pixel_width, pixel_height = o.text_pixel_size_clamped()
        local window_width, window_height = o.window_size()
        local width_percent = pixel_width / window_width
        local height_percent = pixel_height / window_height
        width_percent = width_percent > 1 and 1 or width_percent
        height_percent = height_percent > 1 and 1 or height_percent
        width_percent = width_percent < 0 and 0 or width_percent
        height_percent = height_percent < 0 and 0 or height_percent
        width_percent = math.floor(width_percent * 1000) / 1000
        height_percent = math.floor(height_percent * 1000) / 1000
        return width_percent, height_percent
    end)

    ---@type reactive.computed
    o.factory.text_pixel_size_clamped.computed(function()
        ---@type framework.ui.text.render_result
        local render_result = render_text_clamped()
        return render_result.width, render_result.height
    end)

    ---@type reactive.computed
    o.factory.text_relative_size_unlimited.computed(function()
        local pixel_width, pixel_height = o.text_pixel_size_unlimited()
        local window_width, window_height = o.window_size()
        local width_percent = pixel_width / window_width
        local height_percent = pixel_height / window_height
        width_percent = width_percent > 1 and 1 or width_percent
        height_percent = height_percent > 1 and 1 or height_percent
        width_percent = width_percent < 0 and 0 or width_percent
        height_percent = height_percent < 0 and 0 or height_percent
        width_percent = math.floor(width_percent * 1000) / 1000
        height_percent = math.floor(height_percent * 1000) / 1000
        return width_percent, height_percent
    end)

    ---@type reactive.computed
    o.factory.text_pixel_size_unlimited.computed(function()
        ---@type framework.ui.text.render_result
        local render_result = render_text_unlimited()
        return render_result.width, render_result.height
    end)

    -- 应用文本渲染结果
    render_text_clamped.on_change.add(function(render_result)
        apis.SET_TEXT({ handle = o.handle(), text = render_result.text })
        o.visual_size.compute(function()
            local scale = settings.UI_APPLICATION_SIZE_SCALE
            return render_result.width * scale, render_result.height * scale
        end)
    end)

    -- 字体大小
    o.font_size.wrap_set(function(font_size)
        font_size = font_size < 0.001 and 0.001 or font_size
        font_size = font_size > 1 and 1 or font_size
        return math.floor(font_size * 1000) / 1000
    end)
    o.font_size.on_change.add(function(font_size)
        local api = apis.SET_FONT_SIZE({ handle = o.handle(), size = font_size })
        local pixel_size = api.value or font_size
        o.font_pixel_size.set(pixel_size)
    end)

    o.text.wrap_set(function(content)
        return content or ""
    end)

    o.text_relative_size_clamped.auto_update()
    o.text_relative_size_unlimited.auto_update()

    api.ui = o
end)
