---@class models.ui
local g = require ".base"
---@type models.player
local Player = require "models.player"

---@type string 根节点
local ROOT_HANDLE = "b51d8eb4-56f8-4bf7-a02c-b1ae477d97e4"

---@alias ui.handle UI

---@type table<ui.handle, LocalUILogic> 句柄-逻辑映射表
local HANDLE_TO_LOGIC = {}

-- 是否是文本
---@param ui ui
---@return boolean
local function is_text(ui)
    return ui.type == "text"
end

-- 是否是环形进度条
---@param ui ui
---@return boolean
local function is_progress_ring(ui)
    return ui.type == "progress_ring"
end

-- 是否是条形进度条
---@param ui ui
---@return boolean
local function is_progress_bar(ui)
    return ui.type == "progress_bar"
end

-- 是否是进度条
---@param ui ui
---@return boolean
local function is_progress(ui)
    return is_progress_ring(ui) or is_progress_bar(ui)
end

-- 得到环形进度条的图片
---@param ui ui
---@return ui.handle?
local function get_progress_ring_image(ui)
    if is_progress_ring(ui) then
        local handle = ui.handle():get_child('progress_bar_img')
        assert(handle, "progress_bar_img not found")
        return handle
    end
end

-- 得到条形进度条的图片
---@param ui ui
---@return ui.handle?
local function get_progress_bar_image(ui)
    if is_progress_bar(ui) then
        local handle = ui.handle():get_child('progress_bar_img')
        assert(handle, "progress_bar_img not found")
        return handle
    end
end

g.set_text = function(handle, text)
    handle:set_text(text)
end

g.set_visible = function(handle, visible)
    handle:set_visible(visible)
end

g.set_model = function(handle, model)
    handle:set_ui_model_id(model)
end

g.new = function(type, parent_handle)
    type = type or "void"
    local parent_name = (parent_handle and parent_handle.handle) or ROOT_HANDLE
    local map_type = {
        ["void"] = 7,
        ["button"] = 1,
        ["text"] = 3,
        ["image"] = 4,
        ["progress_ring"] = 42,
        ["progress_bar"] = 41,
        ["model"] = 6,
        ["slider"] = 11,
        ["input"] = 15,
        ["effect"] = 49,
    }
    local type_id = map_type[type]
    local comp_name = GameAPI.create_ui_comp(Player.get_local().handle().handle, parent_name, type_id)
    local handle = y3.ui.get_by_handle(Player.get_local().handle(), comp_name)

    -- 逻辑
    local logic = y3.local_ui.create(handle)
    HANDLE_TO_LOGIC[handle] = logic

    -- 模型
    if type == "model" then
        -- 去掉背景
        handle:set_show_room_background_color(0, 0, 0, 0)
        -- 智能全身镜头
        GameAPI.set_model_comp_camera_mod(Player.get_local().handle().handle, handle.handle, 1)
    end
    -- 环形进度条
    if type == "progress_ring" then
        -- 隐藏没用的
        local child_bg = handle:get_child('progress_bg_img')
        if child_bg then
            child_bg:set_visible(false)
        end
        local child_percent = handle:get_child('progress_percent_label')
        if child_percent then
            child_percent:set_visible(false)
        end
    end
    -- 条形进度条
    if type == "progress_bar" then
        -- 隐藏没用的
        local child_bg = handle:get_child('progress_bg_img')
        if child_bg then
            child_bg:set_visible(false)
        end
        local child_percent = handle:get_child('progress_percent_label')
        if child_percent then
            child_percent:set_visible(false)
        end
    end
    -- 特效
    if type == "effect" then
        -- 去掉背景
        handle:set_effect_background_color(0, 0, 0, 0)
        handle:set_effect_camera_mode('智能模式')
    end
    -- 文本
    if type == "text" then
        -- 宽度自适应 = 4
        -- 不处理 = 3
        -- 字体自适应 = 2
        -- 框体自适应 = 1
        -- 截断文本 = 0
        
        local value = 3
        GameAPI.set_text_over_length_handling_type(Player.get_local().handle().handle, comp_name,value --[[@as py.DynamicTypeMeta]])
    end

    return handle
end

g.play_effect = function(handle, effect, is_loop,speed)
    is_loop = is_loop or false
    speed = speed or 1
    handle:play_ui_effect(effect, is_loop)
    handle:set_effect_play_speed(speed)
end

g.play_anima = function(handle, anima, is_loop,speed)
    is_loop = is_loop or false
    speed = speed or 1
    GameAPI.play_ui_model_anim(Player.get_local().handle().handle,handle.handle,anima,speed,nil,nil,is_loop,true)
end

g.delete = function(handle)
    local logic = HANDLE_TO_LOGIC[handle]
    if logic then
        logic:remove()
    end
    handle:remove()
    HANDLE_TO_LOGIC[handle] = nil
end

---绑定事件
---@param handle ui.handle 句柄
---@param event y3.Const.UIEvent 事件
---@param func fun() 回调函数
---@return fun() 删除函数
local function on_event(handle, event, func)
    local logic = HANDLE_TO_LOGIC[handle]
    logic:on_event('',event, function(ui, local_player, logic)
        func()
    end)

    return function()
    end
end

g.on_mouse_focus = function(handle, func)
    return on_event(handle, '鼠标-移入', func)
end

g.on_mouse_blur = function(handle, func)
    return on_event(handle, '鼠标-移出', func)
end

g.on_mouse_left_down = function(handle, func)
    return on_event(handle, '左键-按下', func)
end

g.on_mouse_left_up = function(handle, func)
    return on_event(handle, '左键-抬起', func)
end

g.on_mouse_right_down = function(handle, func)
    return on_event(handle, '右键-按下', func)
end

g.on_mouse_right_up = function(handle, func)
    return on_event(handle, '右键-抬起', func)
end

g.set_image = function(ui, image)
    local handle
    if not handle then
        handle = get_progress_ring_image(ui)
    end
    if not handle then
        handle = get_progress_bar_image(ui)
    end
    if not handle then
        handle = ui.handle()
    end
    handle:set_image(image)
end

g.set_image_color = function(ui, color)
    local handle
    if not handle then
        handle = get_progress_ring_image(ui)
    end
    if not handle then
        handle = get_progress_bar_image(ui)
    end
    if not handle then
        handle = ui.handle()
    end
    handle:set_image_color(color.red, color.green, color.blue, 255)
end

g.set_alpha = function(handle, alpha)
    handle:set_alpha(alpha)
end

g.get_window_height = function()
    return GameAPI.get_window_real_y_size()
end

g.get_window_width = function()
    return GameAPI.get_window_real_x_size()
end

g.set_size = function (ui, width, height)
    local handle
    if not handle then
        handle = get_progress_ring_image(ui)
    end
    if not handle then
        handle = get_progress_bar_image(ui)
    end
    if not handle then
        handle = ui.handle()
    end
    handle:set_ui_size(width/2, height/2)
end

g.set_font_size = function(handle, size)
    local max = 100

    local value = math.floor(max * size)
    handle:set_font_size(value)

    return value
end

g.set_text_alignment = function(handle, pos)
    local h,v
    if pos == "left_top" or pos == "top_left" then
        h = '左'
        v = '上'
    elseif pos == "center_top" or pos == "top_center" then
        h = '中'
        v = '上'
    elseif pos == "right_top" or pos == "top_right" then
        h = '右'
        v = '上'
    elseif pos == "center_left" or pos == "left_center" then
        h = '左'
        v = '中'
    elseif pos == "center" then
        h = '中'
        v = '中'
    elseif pos == "center_right" or pos == "right_center" then
        h = '右'
        v = '中'
    elseif pos == "left_bottom" or pos == "bottom_left" then
        h = '左'
        v = '下'
    elseif pos == "center_bottom" or pos == "bottom_center" then
        h = '中'
        v = '下'
    elseif pos == "right_bottom" or pos == "bottom_right" then
        h = '右'
        v = '下'
    end
    handle:set_text_alignment(h, v)
end

g.set_position = function(ui, x, y)
    ui.handle():set_absolute_pos(x, y)
end

g.set_progress = function(ui, progress)
    progress = (progress > 1 and 1) or progress
    progress = (progress < 0 and 0) or progress
    progress = progress * 100
    ui.handle():set_current_progress_bar_value(progress)
end

g.set_rotation = function(ui, rotation)
    local handle
    if not handle then
        handle = get_progress_ring_image(ui)
    end
    if not handle then
        handle = get_progress_bar_image(ui)
    end
    if not handle then
        handle = ui.handle
    end

    ui.handle():set_widget_absolute_rotation(rotation)
end

--[[
g.set_rotation = function(ui, rotation)
    local handle
    if not handle then
        handle = get_progress_ring_image(ui)
    end
    if not handle then
        handle = ui.handle
    end

    local value = rotation
    if is_progress_ring(ui) then
        if TO_ROTATION[ui.handle] then
            value = value - TO_ROTATION[ui.handle]
        end
    end

    ui.handle:set_widget_absolute_rotation(value)

    -- 记录
    TO_ROTATION[ui.handle] = rotation
end

g.set_progress_rotation = function(ui, progress_rotation)
    if not is_progress(ui) then
        return
    end

    progress_rotation = progress_rotation + 135
    ui.handle:set_widget_absolute_rotation(progress_rotation)

    if is_progress_ring(ui) then
        if TO_ROTATION[ui.handle] then
            g.set_rotation(ui, TO_ROTATION[ui.handle])
        end
    end
end
]]
-- 图层
g.LAYER.DEFAULT = g.new()
g.LAYER.WINDOW = g.new()
g.LAYER.HUD = g.new()
g.LAYER.SYSTEM = g.new()
g.LAYER.CINEMATIC = g.new()