---@class models.ui
---@field new fun(type?:ui.type, parent_handle?:ui.handle):ui.handle 创建框架
---@field on_mouse_focus fun(ui: ui.handle,func:fun()):fun()  绑定鼠标移入事件。返回删除函数
---@field on_mouse_blur fun(ui: ui.handle,func:fun()):fun() 绑定鼠标移出事件。返回删除函数
---@field on_mouse_left_down fun(ui: ui.handle,func:fun()):fun() 绑定鼠标左键按下事件。返回删除函数
---@field on_mouse_left_up fun(ui: ui.handle,func:fun()):fun() 绑定鼠标左键抬起事件。返回删除函数
---@field on_mouse_right_down fun(ui: ui.handle,func:fun()):fun() 绑定鼠标右键按下事件。返回删除函数
---@field on_mouse_right_up fun(ui: ui.handle,func:fun()):fun() 绑定鼠标右键抬起事件。返回删除函数
---@field set_text fun(handle:ui.handle, text:string) 设置文本
---@field set_visible fun(handle:ui.handle, visible:boolean) 设置显隐
---@field set_model fun(handle:ui.handle, model:any) 设置模型
---@field play_effect fun(handle:ui.handle, effect:any,is_loop?:boolean,speed?:number) 播放特效
---@field play_anima fun(handle:ui.handle, anima:any,is_loop?:boolean,speed?:number) 播放动画
---@field delete fun(handle:ui.handle) 删除
---@field set_image fun(ui:ui, image:py.Texture|string) 设置图片
---@field set_image_color fun(ui:ui, color:color) 设置图片颜色
---@field set_alpha fun(handle:ui.handle, alpha:number) 设置透明度
---@field set_size fun(ui:ui, width:number, height:number) 设置尺寸
---@field set_font_size fun(handle:ui.handle, size:number):number 设置字体大小（百分比），返回字体像素大小
---@field set_text_alignment fun(handle:ui.handle, pos:ui.position) 设置文本对齐方式
---@field set_position fun(ui:ui, x:number, y:number) 设置像素级位置（右和上为正方向）
---@field get_window_width fun():integer 获取窗口宽度
---@field get_window_height fun():integer 获取窗口高度
---@field set_progress fun(ui:ui, progress:number) 设置进度条（百分比）
---@field set_rotation fun(ui:ui, rotation:number) 设置旋转（角度）
local g = {}
---@type utils.hook
local hook = require "utils.hook"
---@type models.event
local event = require "models.event"

---@type table<ui.handle, ui> 句柄-对象映射表
g.HANDLE_TO_OBJECT = {}

---@alias ui.type
---| "void" -- 空类型
---| "button" -- 按钮类型
---| "text" -- 文本类型
---| "image" -- 图片类型
---| "progress_ring" -- 环形进度条类型
---| "progress_bar" -- 条形进度条类型
---| "model" -- 模型类型
---| "slider" -- 滑块类型
---| "input" -- 输入框类型
---| "effect" -- 特效类型

---@alias ui.position
---| "left_top" -- 左上
---| "top_left" -- 上左
---| "center_top" -- 中上
---| "top_center" -- 上中
---| "right_top" -- 右上
---| "top_right" -- 上右
---| "center_left" -- 中左
---| "left_center" -- 左中
---| "center" -- 中
---| "center_right" -- 中右
---| "right_center" -- 右中
---| "left_bottom" -- 左下
---| "bottom_left" -- 下左
---| "center_bottom" -- 下中
---| "bottom_center" -- 下中
---| "right_bottom" -- 右下
---| "bottom_right" -- 下右

---@class ui.anchor
---@field point? ui.position 自身方位
---@field relative_point? ui.position 目标方位
---@field x? number x偏移量（向右为正）
---@field y? number y偏移量（向上为正）
---@field relative_ui? ui? 目标UI（为空表示全局）

---@param args ui.anchor? 锚定数据
---@return ui.anchor 返回锚定数据
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

---@type hook.event 鼠标移动事件（百分比位置: point）
g.ON_MOUSE_MOVE_ASYNC = hook.event()
---@param data event.input
event.ON_MOUSE_MOVE_ASYNC.add(function(data)
    g.ON_MOUSE_MOVE_ASYNC({x=data.window_pos.x/g.get_window_width(), y=data.window_pos.y/g.get_window_height()})
end)

---@enum ui.layer 图层
g.LAYER = {
    DEFAULT = nil, ---@type ui.handle 默认
    WINDOW = nil, ---@type ui.handle 窗口
    HUD = nil, ---@type ui.handle HUD
    SYSTEM = nil, ---@type ui.handle 系统
    CINEMATIC = nil, ---@type ui.handle 过场动画
}

---@type hook.event<integer,integer> 窗口大小改变事件
g.ON_WINDOW_SIZE_CHANGE = hook.event()

return g