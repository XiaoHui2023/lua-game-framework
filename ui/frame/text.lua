---@type lib.stringx
local string = require "lib.stringx"
---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
---@field DEFAULT_TEXT_FONT any 榛樿瀛椾綋
---@field DEFAULT_TEXT_FONT_SIZE number 榛樿瀛椾綋澶у皬
---@field DEFAULT_TEXT_ALIGN ui.position 榛樿瀵归綈鏂瑰紡
---@field TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE number 寰楀埌鏂囨湰鍍忕礌灏哄鐨勫搴︾缉鏀惧€嶆暟
---@field TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE number 寰楀埌鏂囨湰鍍忕礌灏哄鐨勯珮搴︾缉鏀惧€嶆暟
local g = require "..base"
---@type framework.event
local event = require "framework.event"

g.DEFAULT_TEXT_FONT = nil
g.DEFAULT_TEXT_FONT_SIZE = 0.14
g.DEFAULT_TEXT_ALIGN = "center"
g.TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE = 1.8
g.TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE = 3.4

---@class ui.options
---@field text? string 鏂囨湰
---@field font_size? number 瀛椾綋澶у皬锛堢櫨鍒嗘瘮锛?
---@field font? any 瀛椾綋

---@class ui.text.render_result
---@field text string 鏂囨湰
---@field width number 瀹藉害
---@field height number 楂樺害

---@param args? ui.options
---@param ... ui.options
---@return ui.text 杩斿洖瀵硅薄
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

    ---@type hook.set 瀛椾綋
    o.font = o.factory.set(args.font)

    ---@type hook.set 瀛椾綋鍍忕礌澶у皬
    o.font_pixel_size = o.factory.set(0)

    ---@type hook.set 瀛椾綋澶у皬
    o.font_size = o.factory.set(args.font_size)

    ---@type hook.set 鏂囨湰鍐呭
    o.text = o.factory.set(args.text)

    ---@type hook.set 瀵归綈鏂瑰紡
    o.align = o.factory.set(args.align)
    o.align.on_change.add(function(align)
        g.set_text_alignment(o.handle(), align)
    end)

    ---@type hook.computed <ui.text.render_result> 鍙楅檺鍒剁殑鏂囨湰娓叉煋缁撴灉锛屽湪鏂囨湰鍐呭鎴栧瓧浣撳ぇ灏忓彉鍖栨椂锛岄噸鏂版覆鏌撴枃鏈紙鍔犲叆鎹㈣锛夛紝璁＄畻娓叉煋鍚庣殑澶у皬
    local render_text_clamped = o.factory.computed(function()
        local pixel_width = o.pixel_size()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size(),pixel_width)

        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type hook.computed <ui.text.render_result> 鏂囨湰娓叉煋缁撴灉锛屽湪鏂囨湰鍐呭鎴栧瓧浣撳ぇ灏忓彉鍖栨椂锛岄噸鏂版覆鏌撴枃鏈紙鍔犲叆鎹㈣锛夛紝璁＄畻娓叉煋鍚庣殑澶у皬
    local render_text_unlimited = o.factory.computed(function()
        local text, width, height = string.adapt(o.text(),o.font_pixel_size())
        return {
            text = text,
            width = width,
            height = height,
        }
    end)

    ---@type hook.computed 鍙楅檺鍒剁殑鏂囨湰鐧惧垎姣斿ぇ灏?number,number>
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

    ---@type hook.computed 鍙楅檺鍒剁殑鏂囨湰鍍忕礌澶у皬<number,number>
    o.text_pixel_size_clamped = o.factory.computed(function()
        ---@type ui.text.render_result
        local render_result = render_text_clamped()
        return render_result.width, render_result.height
    end)

    ---@type hook.computed 鏈檺鍒剁殑鏂囨湰鐧惧垎姣斿ぇ灏?number,number>
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

    ---@type hook.computed 鏈檺鍒剁殑鏂囨湰鍍忕礌澶у皬<number,number>
    o.text_pixel_size_unlimited = o.factory.computed(function()
        ---@type ui.text.render_result
        local render_result = render_text_unlimited()
        return render_result.width, render_result.height
    end)

    -- 搴旂敤娓叉煋
    render_text_clamped.on_change.add(function(render_result)
        g.set_text(o.handle(), render_result.text)
        o.visual_size.compute(function()
            return render_result.width, render_result.height
        end)
    end)

    -- 瀛椾綋澶у皬
    o.font_size.wrap_set(function(font_size)
        font_size = font_size < 0.001 and 0.001 or font_size
        font_size = font_size > 1 and 1 or font_size
        return math.floor(font_size * 1000) / 1000
    end)
    -- 瀛椾綋澶у皬鏀瑰彉鏃讹紝璁剧疆瀛椾綋鍍忕礌澶у皬
    o.font_size.on_change.add(function(font_size)
        local pixel_size = g.set_font_size(o.handle(),font_size)
        o.font_pixel_size.set(pixel_size)
    end)

    -- 鏂囨湰
    o.text.wrap_set(function(content)
        return content or ""
    end)

    -- 缁戝畾鍒板抚鏇存柊
    o.text_relative_size_clamped.auto_update()
    o.text_relative_size_unlimited.auto_update()

    return o
end