---@type lib.stringx
local string = require "lib.stringx"
---@class framework.ui
local M = require "framework.ui"
---@type jass
local jass = require "jass"

---@class framework.ui.editbox.options : ui.options
---@field length_limit number 最大输入字符数
---@field is_int boolean 是否限制为整数输入
---@field content string 初始输入内容

---@param args framework.ui.editbox.options
---@return ui.editbox 输入框 UI 对象
M.editbox = function(args)
    args = args or {}
    if M.DEFAULT_EDITBOX_FRAME then
        args.label = args.label or M.DEFAULT_EDITBOX_FRAME()
    end
    args.type = args.type or "input"
    args.width = args.width or 0.2
    args.height = args.height or 0.04
    args.length_limit = args.length_limit or 8
    args.is_int = args.is_int or false
    args.content = args.content or ""

    ---@class ui.editbox : ui
    local o = M.create(args)

    ---@type lib.reactive.ref
    o.is_int = o.factory.set(args.is_int)

    ---@type lib.reactive.ref
    o.on_input_change = o.factory.event()

    ---@type lib.reactive.ref
    o.content = o.factory.set(args.content)

    ---@type lib.reactive.ref
    o.length_limit = o.factory.set(args.length_limit)

    o.factory.interval(
        function()
            local new_content = jass.dzapi.frame_get_text(o.handle())
            local old_content = o.content()

            if new_content ~= old_content then
                o.content.set(new_content)
                o.on_input_change(new_content, old_content)
            end
        end
    )

    o.on_input_change.add(
        function(new_content, old_content)
            if o.is_int() then
                local s = string.tointeger(new_content)

                if s ~= new_content then
                    s = "0"
                end

                -- set
                o.content.set(s)
                jass.dzapi.frame_set_text(o.handle(), s)
            end
        end
    )

    jass.dzapi.frame_set_text_limit(o.handle(), o.length_limit())

    return o
end
