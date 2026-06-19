---@type lib.stringx
local string = require "lib.stringx"
---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
---@field DEFAULT_TEXT_FONT any 默认文本字体资源
---@field DEFAULT_TEXT_FONT_SIZE number 默认字体大小比例
---@field DEFAULT_TEXT_ALIGN ui.position 默认文本排列位置
---@field TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE number 文本宽度估算缩放系数
---@field TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE number 文本高度估算缩放系数
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "..apis"
---@type framework.event
local event = require "framework.event"

M.DEFAULT_TEXT_FONT = nil
M.DEFAULT_TEXT_FONT_SIZE = 0.14
M.DEFAULT_TEXT_ALIGN = "center"
M.TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE = 1.8
M.TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE = 3.4

---@class ui.options
---@field text? string 初始显示文本
---@field font_size? number 字体大小比例
---@field font? any 字体资源

---@class ui.text.render_result
---@field text string 实际渲染文本
---@field width number 文本像素宽度
---@field height number 文本像素高度

---@param args? ui.options 文本创建参数
---@param ... ui.options
---@return ui.text 文本 UI 对象
M.text = function(args, ...)
    args = args or {}
    args = table.merge(args, ...)
    args.text = args.text or ""
    args.font_size = args.font_size or M.DEFAULT_TEXT_FONT_SIZE
    args.align = args.align or M.DEFAULT_TEXT_ALIGN
    args.type = args.type or "text"
    args.font = args.font or M.DEFAULT_TEXT_FONT
    args.size = args.size or 1
    args.size_mode = args.size_mode or "contain"

    ---@class ui.text : ui
    local o = M.create(args)

    ---@type lib.reactive.ref 字体资源
    o.font = o.factory.set(args.font)

    ---@type lib.reactive.ref
    o.font_pixel_size = o.factory.set(0)

    ---@type lib.reactive.ref 字体大小比例
    o.font_size = o.factory.set(args.font_size)

    ---@type lib.reactive.ref
    o.text = o.factory.set(args.text)

    ---@type lib.reactive.ref
    o.align = o.factory.set(args.align)
    o.align.on_change.add(function(align)
        apis.SET_TEXT_ALIGNMENT({ handle = o.handle(), pos = align })
    end)

    ---@type lib.reactive.ref
    o.outline = o.factory.set(args.outline)
    o.outline.on_change.add(function(outline)
        apis.SET_TEXT_OUTLINE({ handle = o.handle(), outline = outline })
    end)

    ---@type reactive.computed <ui.text.render_result>
    local render_text_clamped = o.factory.computed(function()
        local pixel_width = o.pixel_size()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size(),pixel_width)

        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type reactive.computed <ui.text.render_result>
    local render_text_unlimited = o.factory.computed(function()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size())
        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type reactive.computed
    o.text_relative_size_clamped = o.factory.computed(function()
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
    o.text_pixel_size_clamped = o.factory.computed(function()
        ---@type ui.text.render_result
        local render_result = render_text_clamped()
        return render_result.width, render_result.height
    end)

    ---@type reactive.computed
    o.text_relative_size_unlimited = o.factory.computed(function()
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
    o.text_pixel_size_unlimited = o.factory.computed(function()
        ---@type ui.text.render_result
        local render_result = render_text_unlimited()
        return render_result.width, render_result.height
    end)

    -- 应用文本渲染结果
    render_text_clamped.on_change.add(function(render_result)
        apis.SET_TEXT({ handle = o.handle(), text = render_result.text })
        o.visual_size.compute(function()
            return render_result.width, render_result.height
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

    return o
end
