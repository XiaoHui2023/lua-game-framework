---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@class ui.options
---@field dragable? boolean 是否允许拖拽

---@param o ui
---@param args ui.options
return function (o,args)
    args.dragable = args.dragable or false

    ---@class ui
    o = o

    ---@type lib.reactive.ref 是否可以拖拽
    o.draggable = o.factory.set(args.dragable)

    ---@type reactive.event 拖拽开始事件
    o.on_drag_start = o.factory.event()

    ---@type reactive.event 拖拽事件（百分比位置: point）
    o.on_drag = o.factory.event()

    ---@type reactive.event 拖拽结束事件
    o.on_drag_end = o.factory.event()

    ---@type lib.reactive.ref 当前是否拖拽
    o.is_dragging = o.factory.set(false)

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
            -- 是否开启使能
            if not o.draggable() then
                return
            end
            -- 需要可见
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
