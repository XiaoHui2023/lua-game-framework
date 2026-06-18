---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.ui
---@field new fun(type
---@field on_mouse_focus fun(ui: ui.handle,func:fun()):fun()  缂佹垵鐣炬Η鐘崇垼缁夎
---@field set_visible fun(handle:ui.handle, visible:boolean) 璁剧疆鏄鹃殣
---@field set_model fun(handle:ui.handle, model:any) 鐠佸墽鐤嗗Ο鈥崇€
---@field play_effect fun(handle:ui.handle, effect:any,is_loop
---@field play_anima fun(handle:ui.handle, anima:any,is_loop
---@field delete fun(handle:ui.handle) 閸掔娀娅
---@field set_image fun(ui:ui, image:py.Texture|string) 璁剧疆鍥剧墖
---@field set_image_color fun(ui:ui, color:color) 鐠佸墽鐤嗛崶鍓у
---@field set_alpha fun(handle:ui.handle, alpha:number) 鐠佸墽鐤嗛柅蹇旀
---@field set_font_size fun(handle:ui.handle, size:number):number 鐠佸墽鐤嗙€涙ぞ缍嬫径褍鐨
---@field set_text_alignment fun(handle:ui.handle, pos:ui.position) 鐠佸墽鐤嗛弬鍥ㄦ拱鐎靛綊缍堥弬鐟扮础
---@field set_position fun(ui:ui, x:number, y:number) 鐠佸墽鐤嗛崓蹇曠
---@field get_window_height fun():integer 閼惧嘲褰囩粣妤€褰涙
---@field set_progress fun(ui:ui, progress:number) 鐠佸墽鐤嗘潻娑樺
---@field set_rotation fun(ui:ui, rotation:number) 鐠佸墽鐤嗛弮瀣
local g = {}
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.event
local event = require "framework.event"
---@type framework.ui.apis
local apis = require ".apis"

---@type table<ui.handle, ui> 閸欍儲鐒

---@alias ui.type
---| "void" -- 缁岃櫣琚
---| "text" -- 閺傚洦婀扮猾璇茬€
---| "image" -- 閸ュ墽澧栫猾璇茬€
---| "progress_ring" -- 閻滎垰鑸版潻娑樺
---| "slider" -- 濠婃垵娼＄猾璇茬€
---| "input" -- 鏉堟挸鍙嗗

---@alias ui.position
---| "left_top" -- 瀹革缚绗
---| "top_left" -- 娑撳﹤涔
---| "center_top" -- 娑擃厺绗
---| "top_center" -- 娑撳﹣鑵
---| "right_top" -- 閸欏厖绗
---| "top_right" -- 娑撳﹤褰
---| "center_left" -- 娑擃厼涔
---| "left_center" -- 瀹革缚鑵
---| "center" --
---| "center_right" -- 娑擃厼褰
---| "right_center" -- 閸欏厖鑵
---| "left_bottom" -- 瀹革缚绗
---| "bottom_left" -- 娑撳
---| "center_bottom" -- 娑撳
---| "bottom_center" -- 娑撳
---| "right_bottom" -- 閸欏厖绗
---| "bottom_right" -- 娑撳

---@class ui.anchor
---@field point
---@field relative_point
---@field x
---@param args ui.anchor
---@return ui.anchor 鏉╂柨娲栭柨姘
g.anchor = function(args)
    ---@class ui.anchor
    args = args or {}
    args.point = args.point or "center"
    args.relative_point = args.relative_point or "center"
    args.x = args.x or 0
    args.y = args.y or 0

    return metatable.with_tostring(args, function()
        local fields = {args.point,args.relative_point}
        if args.x and args.x ~= 0 then
            table.insert(fields, string.format("x=%.2f", args.x))
        end
        if args.y and args.y ~= 0 then
            table.insert(fields, string.format("y=%.2f", args.y))
        end
        if args.relative_ui then
            table.insert(fields, tostring(args.relative_ui))
        end
        local attrs = table.concat(fields, ",")
        return string.format("<ui.anchor %s>", attrs)
    end)
end

---@type reactive.event ????????????: point?
---@param api event.InputAsync
event.ON_MOUSE_MOVE_ASYNC(function(api)
    local data = api.input
    g.ON_MOUSE_MOVE_ASYNC({
        position = {
            x = data.window_pos.x / g.get_window_width(),
            y = data.window_pos.y / g.get_window_height(),
        },
    })
end)

---@enum ui.layer
g.LAYER = {
    DEFAULT = nil, ---@type ui.handle ???
    WINDOW = nil, ---@type ui.handle ???
    HUD = nil, ---@type ui.handle HUD
    SYSTEM = nil, ---@type ui.handle ???
    CINEMATIC = nil, ---@type ui.handle ???
}

---@type reactive.event<integer,integer> 缁愭
g.ON_WINDOW_SIZE_CHANGE = apis.ON_WINDOW_SIZE_CHANGE

return g
