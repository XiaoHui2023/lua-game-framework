---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.ui
---@field new fun(type?:ui.type, name?:string):ui 创建 UI 主对象
---@field on_mouse_focus fun(ui:ui, on_focus:function, on_blur:function) 注册鼠标焦点回调
---@field set_visible fun(handle:ui.handle, is_visible:boolean) 设置 UI 可见状态
---@field set_model fun(handle:ui.handle, model:any) 设置 UI 模型资源
---@field play_effect fun(handle:ui.handle, effect:any, is_loop?:boolean) 播放 UI 特效
---@field play_anima fun(handle:ui.handle, anima:any, is_loop?:boolean) 播放 UI 动画
---@field delete fun(handle:ui.handle) 删除 UI 实例
---@field set_image fun(ui:ui, image:any) 设置 UI 图片
---@field set_image_color fun(ui:ui, color:color) 设置 UI 图片颜色
---@field set_alpha fun(handle:ui.handle, alpha:number) 设置 UI 透明度
---@field set_font_size fun(handle:ui.handle, size:number) 设置 UI 字号
---@field set_text_alignment fun(handle:ui.handle, align:string) 设置 UI 文本排列
---@field set_position fun(ui:ui, position:point) 设置 UI 位置
---@field get_window_height fun():integer 获取窗口高度
---@field set_progress fun(ui:ui, progress:number) 设置进度 UI 数值
---@field set_rotation fun(ui:ui, rotation:number) 设置 UI 绝对旋转
local M = {}
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.ui.apis
local apis = require ".apis"
M.apis = apis

---@type table<ui.handle, ui>
M.HANDLE_TO_OBJECT = {}

---@alias ui.type
---| "void" -- 空节点
---| "text"
---| "image"
---| "progress_ring"
---| "slider" -- 滑条
---| "input"

---@alias ui.position
---| "left_top" -- 左上
---| "top_left" -- 上左
---| "center_top" -- 中上
---| "top_center"
---| "right_top"
---| "top_right" -- 上右
---| "center_left" -- 中左
---| "left_center"
---| "center" -- 中心
---| "center_right" -- 中右
---| "right_center"
---| "left_bottom" -- 左下
---| "bottom_left" -- 下左
---| "center_bottom" -- 中下
---| "bottom_center" -- 下中
---| "right_bottom"
---| "bottom_right" -- 下右

---@class ui.anchor
---@field point ui.position 当前 UI 锚点方位
---@field relative_point ui.position 目标锚点方位
---@field x number 横向偏移比例
---@field y number 纵向偏移比例
---@field relative_ui? ui 相对定位目标
---@param args ui.anchor
---@return ui.anchor 规范化后的锚点配置
M.anchor = function(args)
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

---@enum ui.layer
M.LAYER = {
    DEFAULT = nil, ---@type ui.handle default layer
    WINDOW = nil, ---@type ui.handle window layer
    HUD = nil, ---@type ui.handle HUD
    SYSTEM = nil, ---@type ui.handle system layer
    CINEMATIC = nil, ---@type ui.handle cinematic layer
}

---@type reactive.event<integer,integer> 异步鼠标移动事件
M.ON_MOUSE_MOVE_ASYNC = apis.ON_MOUSE_MOVE_ASYNC
M.ON_WINDOW_SIZE_CHANGE = apis.ON_WINDOW_SIZE_CHANGE
M.ON_CREATE = apis.ON_CREATE

---@param api lib.callback.api
---@param values table
---@return lib.callback.instance
local function emit(api, values)
    local instance = api:new(values)
    instance:emit()
    return instance
end

---@param type ui.type?
---@param parent_handle ui.handle?
---@return ui.handle
M.new = function(type, parent_handle)
    local api = emit(apis.CREATE, {
        type = type,
        parent_handle = parent_handle,
    })
    assert(api.handle ~= nil, "framework.ui.new requires runtime backend")
    return api.handle
end

M.set_text = function(handle, text)
    emit(apis.SET_TEXT, { handle = handle, text = text })
end

M.set_visible = function(handle, visible)
    emit(apis.SET_VISIBLE, { handle = handle, visible = visible })
end

M.set_model = function(handle, model)
    emit(apis.SET_MODEL, { handle = handle, model = model })
end

M.play_effect = function(handle, effect, is_loop, speed)
    emit(apis.PLAY_EFFECT, { handle = handle, effect = effect, is_loop = is_loop, speed = speed })
end

M.play_anima = function(handle, anima, is_loop, speed)
    emit(apis.PLAY_ANIMA, { handle = handle, anima = anima, is_loop = is_loop, speed = speed })
end

M.delete = function(handle)
    emit(apis.DELETE, { handle = handle })
end

local function on_mouse_event(handle, event, func)
    local api = emit(apis.ON_MOUSE_EVENT, { handle = handle, event = event, func = func })
    return api.remove_func or function()
    end
end

M.on_mouse_focus = function(handle, func)
    return on_mouse_event(handle, '鼠标-移入', func)
end

M.on_mouse_blur = function(handle, func)
    return on_mouse_event(handle, '鼠标-移出', func)
end

M.on_mouse_left_down = function(handle, func)
    return on_mouse_event(handle, '左键-按下', func)
end

M.on_mouse_left_up = function(handle, func)
    return on_mouse_event(handle, '左键-抬起', func)
end

M.on_mouse_right_down = function(handle, func)
    return on_mouse_event(handle, '右键-按下', func)
end

M.on_mouse_right_up = function(handle, func)
    return on_mouse_event(handle, '右键-抬起', func)
end

M.set_image = function(ui, image)
    emit(apis.SET_IMAGE, { ui = ui, image = image })
end

M.set_image_color = function(ui, color)
    emit(apis.SET_IMAGE_COLOR, { ui = ui, color = color })
end

M.set_alpha = function(handle, alpha)
    emit(apis.SET_ALPHA, { handle = handle, alpha = alpha })
end

M.get_window_width = function()
    local api = emit(apis.GET_WINDOW_SIZE, {})
    assert(api.width ~= nil, "framework.ui.get_window_width requires runtime backend")
    return api.width
end

M.get_window_height = function()
    local api = emit(apis.GET_WINDOW_SIZE, {})
    assert(api.height ~= nil, "framework.ui.get_window_height requires runtime backend")
    return api.height
end

M.set_size = function(ui, width, height)
    emit(apis.SET_SIZE, { ui = ui, width = width, height = height })
end

M.set_font_size = function(handle, size)
    local api = emit(apis.SET_FONT_SIZE, { handle = handle, size = size })
    return api.value or size
end

M.set_text_alignment = function(handle, pos)
    emit(apis.SET_TEXT_ALIGNMENT, { handle = handle, pos = pos })
end

M.set_text_outline = function(handle, outline)
    emit(apis.SET_TEXT_OUTLINE, { handle = handle, outline = outline })
end

M.set_position = function(ui, x, y)
    emit(apis.SET_POSITION, { ui = ui, x = x, y = y })
end

M.set_anchor = function(ui, x, y)
    emit(apis.SET_ANCHOR, { ui = ui, x = x, y = y })
end

M.set_progress = function(ui, progress)
    emit(apis.SET_PROGRESS, { ui = ui, progress = progress })
end

M.set_rotation = function(ui, rotation)
    emit(apis.SET_ROTATION, { ui = ui, rotation = rotation })
end

local LAYER_NAMES = {
    DEFAULT = true,
    WINDOW = true,
    HUD = true,
    SYSTEM = true,
    CINEMATIC = true,
}

setmetatable(M.LAYER, {
    __index = function(layers, name)
        if not LAYER_NAMES[name] then
            return nil
        end

        local layer = M.new()
        rawset(layers, name, layer)
        return layer
    end,
})

return M
