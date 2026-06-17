---@type lib.stringx
local string = require "lib.stringx"
---@class framework.ui
local g = require "..base"
---@type jass
local jass = require "jass"

---@class framework.ui.editbox.options : ui.options
---@field length_limit number 闄愬埗瀛楁暟锛岄粯璁?涓?
---@field is_int boolean 鏄惁鍙兘鏁板瓧锛岄粯璁ゅ惁
---@field content string 鍐呭锛岄粯璁ょ┖

---@param args framework.ui.editbox.options
---@return ui.editbox 杩斿洖瀵硅薄
g.editbox = function(args)
    -- 榛樿鍊?
    args.label = args.label or g.DEFAULT_EDITBOX_FRAME()
    args.width = args.width or 0.2
    args.height = args.height or 0.04
    args.length_limit = args.length_limit or 8
    args.is_int = args.is_int or false
    args.content = args.content or ""

    ---@class ui.editbox : ui
    local o = g.create(args)

    ---@type hook.set 鏄惁鍙兘杈撳叆鏁板瓧
    o.is_int = o.factory.set(args.is_int)

    ---@type hook.set 杈撳叆妗嗗唴瀹瑰彉鍖栦簨浠讹紙new_content,old_content锛?
    o.on_input_change = o.factory.event()

    ---@type hook.set 杈撳叆妗嗗唴瀹?
    o.content = o.factory.set(args.content)

    -- 娉ㄥ唽瀹氭椂鍣紝鍝嶅簲 鏂囨湰鍙樺寲
    o.factory.interval(
        function()
            -- 寰楀埌鏂囨湰
            local new_content = jass.dzapi.frame_get_text(o.handle())
            local old_content = o.content()

            -- 鏈夊彉鍖?
            if new_content ~= old_content then
                o.content.set(new_content)
                o.on_input_change(new_content, old_content)
            end
        end
    )

    --- 鏂囨湰鍙樺寲鏃讹紝闄愬畾鏁板瓧
    o.on_input_change.add(
        function(new_content, old_content)
            if o.is_int() then
                -- 杞暣鏁?
                local s = string.tointeger(new_content)

                -- 杞け璐ュ垯鍙樹负0
                if s ~= new_content then
                    s = "0"
                end

                -- set
                o.content.set(s)
                jass.dzapi.frame_set_text(o.handle(), s)
            end
        end
    )

    -- 闄愬埗瀛楁暟
    jass.dzapi.frame_set_text_limit(o.handle(), o.length_limit())

    return o
end
