---@class models.ui
---@field DEFAULT_TEXT_FONT any 默认字体
---@field DEFAULT_TEXT_FONT_SIZE number 默认字体大小
---@field DEFAULT_TEXT_ALIGN ui.position 默认对齐方式
---@field TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE number 得到文本像素尺寸的宽度缩放倍数
---@field TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE number 得到文本像素尺寸的高度缩放倍数
local g = require "..base"
---@type models.event
local event = require "models.event"

g.DEFAULT_TEXT_FONT = nil
g.DEFAULT_TEXT_FONT_SIZE = 0.14
g.DEFAULT_TEXT_ALIGN = "center"
g.TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE = 1.8
g.TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE = 3.4

---@class ui.options
---@field text? string 文本
---@field font_size? number 字体大小（百分比）
---@field font? any 字体

---@class ui.text.render_result
---@field text string 文本
---@field width number 宽度
---@field height number 高度

---@param args? ui.options
---@param ... ui.options
---@return ui.text 返回对象
g.text = function(args, ...)
    args = args or {}
    args = table.merge(args, ...)
    args.text = args.text or ""
    args.font_size = args.font_size or g.DEFAULT_TEXT_FONT_SIZE
    args.align = args.align or g.DEFAULT_TEXT_ALIGN
    args.type = args.type or "text"
    args.font = args.font or g.DEFAULT_TEXT_FONT
    args.size = args.size or 1
    args.size_mode = args.size_mode or "contain"

    ---@class ui.text : ui
    local o = g.create(args)

    ---@type hook.set 字体
    o.font = o.factory.set(args.font)

    ---@type hook.set 字体像素大小
    o.font_pixel_size = o.factory.set(0)

    ---@type hook.set 字体大小
    o.font_size = o.factory.set(args.font_size)

    ---@type hook.set 文本内容
    o.text = o.factory.set(args.text)

    ---@type hook.set 对齐方式
    o.align = o.factory.set(args.align)
    o.align.on_change.add(function(align)
        g.set_text_alignment(o.handle(), align)
    end)

    ---@type hook.computed <ui.text.render_result> 受限制的文本渲染结果，在文本内容或字体大小变化时，重新渲染文本（加入换行），计算渲染后的大小
    local render_text_clamped = o.factory.computed(function()
        local pixel_width = o.pixel_size()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size(),pixel_width)

        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type hook.computed <ui.text.render_result> 文本渲染结果，在文本内容或字体大小变化时，重新渲染文本（加入换行），计算渲染后的大小
    local render_text_unlimited = o.factory.computed(function()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size())
        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type hook.computed 受限制的文本百分比大小<number,number>
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

    ---@type hook.computed 受限制的文本像素大小<number,number>
    o.text_pixel_size_clamped = o.factory.computed(function()
        ---@type ui.text.render_result
        local render_result = render_text_clamped()
        return render_result.width, render_result.height
    end)

    ---@type hook.computed 未限制的文本百分比大小<number,number>
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

    ---@type hook.computed 未限制的文本像素大小<number,number>
    o.text_pixel_size_unlimited = o.factory.computed(function()
        ---@type ui.text.render_result
        local render_result = render_text_unlimited()
        return render_result.width, render_result.height
    end)

    -- 应用渲染
    render_text_clamped.on_change.add(function(render_result)
        g.set_text(o.handle(), render_result.text)
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
    -- 字体大小改变时，设置字体像素大小
    o.font_size.on_change.add(function(font_size)
        local pixel_size = g.set_font_size(o.handle(),font_size)
        o.font_pixel_size.set(pixel_size)
    end)

    -- 文本
    o.text.wrap_set(function(content)
        return content or ""
    end)

    -- 绑定到帧更新
    o.text_relative_size_clamped.auto_update()
    o.text_relative_size_unlimited.auto_update()

    return o
end