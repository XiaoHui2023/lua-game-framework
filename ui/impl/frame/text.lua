---@type lib.stringx
local string = require "lib.stringx"
---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param api framework.ui.api.CreateText
apis.CREATE_TEXT(function(api)
    local args = table.merge(api.options or {}, api.options_extra)
    args.text = args.text or ""
    args.font_size = args.font_size or settings.DEFAULT_TEXT_FONT_SIZE
    args.align = args.align or settings.DEFAULT_TEXT_ALIGN
    args.type = args.type or "text"
    args.font = args.font or settings.DEFAULT_TEXT_FONT
    args.size = args.size or { width = "auto", height = "auto" }

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_TEXT requires CREATE_OBJECT result")
    ---@type framework.ui.text
    local o = create_api.ui

    o.factory.ref_field("font", args.font)
    o.factory.ref_field("font_pixel_size", 0)
    o.factory.ref_field("font_size", args.font_size)
    o.factory.ref_field("text", args.text)
    o.factory.ref_field("align", args.align)
    o.factory.ref_field("outline", args.outline)

    local render_text = o.factory.computed_field("render_text", function()
        local constraints = o.constraints()
        local max_width = constraints.max_width > 0 and constraints.max_width or nil
        local text, width, height = string.adapt(o.text(), o.font_pixel_size(), max_width)
        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    o.content_size.compute(function()
        local render_result = render_text()
        return {
            width = render_result.width,
            height = render_result.height,
        }
    end)

    o.align.on_change.add(function(align)
        apis.SET_TEXT_ALIGNMENT({ handle = o.handle(), pos = align })
    end)
    o.outline.on_change.add(function(outline)
        apis.SET_TEXT_OUTLINE({ handle = o.handle(), outline = outline })
    end)

    render_text.on_change.add(function(render_result)
        apis.SET_TEXT({ handle = o.handle(), text = render_result.text })
    end)

    o.font_size.wrap_set(function(font_size)
        font_size = font_size < 0.001 and 0.001 or font_size
        font_size = font_size > 1 and 1 or font_size
        return math.floor(font_size * 1000) / 1000
    end)
    o.font_size.on_change.add(function(font_size)
        local font_api = apis.SET_FONT_SIZE({ handle = o.handle(), size = font_size })
        o.font_pixel_size.set(font_api.value or font_size)
    end)

    o.text.wrap_set(function(content)
        return content or ""
    end)

    render_text.auto_update()
    api.ui = o
end)

return true
