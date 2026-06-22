---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o framework.ui 要装配拖拽能力的 UI 对象
---@param args framework.ui.options UI 创建参数
return function (o,args)
    args.dragable = args.dragable or false

    ---@class framework.ui
    o = o

    ---@type lib.reactive.ref 是否可以拖拽
    o.factory.draggable.set(args.dragable)

    ---@type reactive.event 拖拽开始事件
    o.factory.on_drag_start.event()

    ---@type reactive.event 拖拽中事件，参数为窗口百分比位置
    o.factory.on_drag.event()

    ---@type reactive.event 拖拽结束事件
    o.factory.on_drag_end.event()

    ---@type lib.reactive.ref 当前是否拖拽
    o.factory.is_dragging.set(false)

    local unbind_move = nil

    local function clear_move()
        if unbind_move then
            unbind_move()
            unbind_move = nil
        end
    end

    local function bind_move()
        clear_move()
        unbind_move = apis.ON_MOUSE_MOVE_ASYNC(function(api)
            o.on_drag(api.position)
        end)
    end

    -- 按下绑定拖拽
    o.on_mouse_left_down.add(
        function()
            -- 未开启拖拽时跳过。
            if not o.draggable() then
                return
            end
            -- 不可见时跳过拖拽。
            if not o.visible() then
                return
            end    

            o.is_dragging.set(true)
            o.on_drag_start()
            bind_move()
        end
    )

    -- 松开结束拖拽
    o.on_mouse_left_up.add(
        function()
            -- 是否正在拖拽
            if not o.is_dragging() then
                return
            end

            o.is_dragging.set(false)
            clear_move()
            o.on_drag_end()
        end
    )

    o.delete.add(clear_move)
end
