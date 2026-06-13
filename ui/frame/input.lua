---@class models.ui
local g = require "..base"
---@type jass
local jass = require "jass"

---@class models.ui.editbox.options : ui.options
---@field length_limit number 限制字数，默认8个
---@field is_int boolean 是否只能数字，默认否
---@field content string 内容，默认空

---@param args models.ui.editbox.options
---@return ui.editbox 返回对象
g.editbox = function(args)
    -- 默认值
    args.label = args.label or g.DEFAULT_EDITBOX_FRAME()
    args.width = args.width or 0.2
    args.height = args.height or 0.04
    args.length_limit = args.length_limit or 8
    args.is_int = args.is_int or false
    args.content = args.content or ""

    ---@class ui.editbox : ui
    local o = g.create(args)

    ---@type hook.set 是否只能输入数字
    o.is_int = o.factory.set(args.is_int)

    ---@type hook.set 输入框内容变化事件（new_content,old_content）
    o.on_input_change = o.factory.event()

    ---@type hook.set 输入框内容
    o.content = o.factory.set(args.content)

    -- 注册定时器，响应 文本变化
    o.factory.interval(
        function()
            -- 得到文本
            local new_content = jass.dzapi.frame_get_text(o.handle())
            local old_content = o.content()

            -- 有变化
            if new_content ~= old_content then
                o.content.set(new_content)
                o.on_input_change(new_content, old_content)
            end
        end
    )

    --- 文本变化时，限定数字
    o.on_input_change.add(
        function(new_content, old_content)
            if o.is_int() then
                -- 转整数
                local s = string.tointeger(new_content)

                -- 转失败则变为0
                if s ~= new_content then
                    s = "0"
                end

                -- set
                o.content.set(s)
                jass.dzapi.frame_set_text(o.handle(), s)
            end
        end
    )

    -- 限制字数
    jass.dzapi.frame_set_text_limit(o.handle(), o.length_limit())

    return o
end
