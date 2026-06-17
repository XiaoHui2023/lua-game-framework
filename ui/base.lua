---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.ui
---@field new fun(type?:ui.type, parent_handle?:ui.handle):ui.handle 鍒涘缓妗嗘灦
---@field on_mouse_focus fun(ui: ui.handle,func:fun()):fun()  缁戝畾榧犳爣绉诲叆浜嬩欢銆傝繑鍥炲垹闄ゅ嚱鏁?---@field on_mouse_blur fun(ui: ui.handle,func:fun()):fun() 缁戝畾榧犳爣绉诲嚭浜嬩欢銆傝繑鍥炲垹闄ゅ嚱鏁?---@field on_mouse_left_down fun(ui: ui.handle,func:fun()):fun() 缁戝畾榧犳爣宸﹂敭鎸変笅浜嬩欢銆傝繑鍥炲垹闄ゅ嚱鏁?---@field on_mouse_left_up fun(ui: ui.handle,func:fun()):fun() 缁戝畾榧犳爣宸﹂敭鎶捣浜嬩欢銆傝繑鍥炲垹闄ゅ嚱鏁?---@field on_mouse_right_down fun(ui: ui.handle,func:fun()):fun() 缁戝畾榧犳爣鍙抽敭鎸変笅浜嬩欢銆傝繑鍥炲垹闄ゅ嚱鏁?---@field on_mouse_right_up fun(ui: ui.handle,func:fun()):fun() 缁戝畾榧犳爣鍙抽敭鎶捣浜嬩欢銆傝繑鍥炲垹闄ゅ嚱鏁?---@field set_text fun(handle:ui.handle, text:string) 璁剧疆鏂囨湰
---@field set_visible fun(handle:ui.handle, visible:boolean) 璁剧疆鏄鹃殣
---@field set_model fun(handle:ui.handle, model:any) 璁剧疆妯″瀷
---@field play_effect fun(handle:ui.handle, effect:any,is_loop?:boolean,speed?:number) 鎾斁鐗规晥
---@field play_anima fun(handle:ui.handle, anima:any,is_loop?:boolean,speed?:number) 鎾斁鍔ㄧ敾
---@field delete fun(handle:ui.handle) 鍒犻櫎
---@field set_image fun(ui:ui, image:py.Texture|string) 璁剧疆鍥剧墖
---@field set_image_color fun(ui:ui, color:color) 璁剧疆鍥剧墖棰滆壊
---@field set_alpha fun(handle:ui.handle, alpha:number) 璁剧疆閫忔槑搴?---@field set_size fun(ui:ui, width:number, height:number) 璁剧疆灏哄
---@field set_font_size fun(handle:ui.handle, size:number):number 璁剧疆瀛椾綋澶у皬锛堢櫨鍒嗘瘮锛夛紝杩斿洖瀛椾綋鍍忕礌澶у皬
---@field set_text_alignment fun(handle:ui.handle, pos:ui.position) 璁剧疆鏂囨湰瀵归綈鏂瑰紡
---@field set_position fun(ui:ui, x:number, y:number) 璁剧疆鍍忕礌绾т綅缃紙鍙冲拰涓婁负姝ｆ柟鍚戯級
---@field get_window_width fun():integer 鑾峰彇绐楀彛瀹藉害
---@field get_window_height fun():integer 鑾峰彇绐楀彛楂樺害
---@field set_progress fun(ui:ui, progress:number) 璁剧疆杩涘害鏉★紙鐧惧垎姣旓級
---@field set_rotation fun(ui:ui, rotation:number) 璁剧疆鏃嬭浆锛堣搴︼級
local g = {}
---@type lib.reactive
local hook = require "lib.reactive"
---@type framework.event
local event = require "framework.event"
---@type framework.ui.apis
local apis = require ".apis"

---@type table<ui.handle, ui> 鍙ユ焺-瀵硅薄鏄犲皠琛?g.HANDLE_TO_OBJECT = {}

---@alias ui.type
---| "void" -- 绌虹被鍨?---| "button" -- 鎸夐挳绫诲瀷
---| "text" -- 鏂囨湰绫诲瀷
---| "image" -- 鍥剧墖绫诲瀷
---| "progress_ring" -- 鐜舰杩涘害鏉＄被鍨?---| "progress_bar" -- 鏉″舰杩涘害鏉＄被鍨?---| "model" -- 妯″瀷绫诲瀷
---| "slider" -- 婊戝潡绫诲瀷
---| "input" -- 杈撳叆妗嗙被鍨?---| "effect" -- 鐗规晥绫诲瀷

---@alias ui.position
---| "left_top" -- 宸︿笂
---| "top_left" -- 涓婂乏
---| "center_top" -- 涓笂
---| "top_center" -- 涓婁腑
---| "right_top" -- 鍙充笂
---| "top_right" -- 涓婂彸
---| "center_left" -- 涓乏
---| "left_center" -- 宸︿腑
---| "center" -- ???
---| "center_right" -- 涓彸
---| "right_center" -- 鍙充腑
---| "left_bottom" -- 宸︿笅
---| "bottom_left" -- 涓嬪乏
---| "center_bottom" -- 涓嬩腑
---| "bottom_center" -- 涓嬩腑
---| "right_bottom" -- 鍙充笅
---| "bottom_right" -- 涓嬪彸

---@class ui.anchor
---@field point? ui.position 鑷韩鏂逛綅
---@field relative_point? ui.position 鐩爣鏂逛綅
---@field x? number x鍋忕Щ閲忥紙鍚戝彸涓烘鏂瑰悜锛?---@field y? number y鍋忕Щ閲忥紙鍚戜笂涓烘鏂瑰悜锛?---@field relative_ui? ui? 鐩爣UI锛堜负绌鸿〃绀哄叏灞€锛?
---@param args ui.anchor? 閿氬畾鏁版嵁
---@return ui.anchor 杩斿洖閿氬畾鏁版嵁
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

---@type hook.event 榧犳爣绉诲姩浜嬩欢锛堢櫨鍒嗘瘮浣嶇疆: point锛?g.ON_MOUSE_MOVE_ASYNC = apis.ON_MOUSE_MOVE_ASYNC
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

---@enum ui.layer 鍥惧眰
g.LAYER = {
    DEFAULT = nil, ---@type ui.handle 榛樿
    WINDOW = nil, ---@type ui.handle 绐楀彛
    HUD = nil, ---@type ui.handle HUD
    SYSTEM = nil, ---@type ui.handle 绯荤粺
    CINEMATIC = nil, ---@type ui.handle 杩囧満鍔ㄧ敾
}

---@type hook.event<integer,integer> 绐楀彛澶у皬鏀瑰彉浜嬩欢
g.ON_WINDOW_SIZE_CHANGE = apis.ON_WINDOW_SIZE_CHANGE

return g
