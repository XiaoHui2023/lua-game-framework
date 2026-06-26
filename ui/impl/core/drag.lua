---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o framework.ui 要装配拖拽能力的 UI 对象
---@param args framework.ui.object_config UI 创建参数
return function (o,args)
    args.draggable = args.draggable or false

    ---@type framework.ui
    o = o
    o.factory.ref_field("draggable", args.draggable)

    o.factory.event_field("on_drag_start")
    o.factory.event_field("on_drag")
    o.factory.event_field("on_drag_end")
    o.factory.ref_field("is_dragging", false)

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
            clear_move()
            if not o.draggable() then
                return
            end
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

    o.factory.delete.add(clear_move)
end
