---@type models.ui
local g = require "..base"

---@class ui.options
---@field dragable? boolean 是否可拖拽，默认否

---@param o ui
---@param args ui.options
return function (o,args)
    args.dragable = args.dragable or false

    ---@class ui
    o = o

    ---@type hook.set 是否可以拖拽
    o.draggable = o.factory.set(args.dragable)

    ---@type hook.event 拖拽开始事件
    o.on_drag_start = o.factory.event()

    ---@type hook.event 拖拽事件（百分比位置: point）
    o.on_drag = o.factory.event()

    ---@type hook.event 拖拽结束事件
    o.on_drag_end = o.factory.event()

    ---@type hook.set 当前是否拖拽
    o.is_dragging = o.factory.set(false)

    local function bind_move()
        ---@param pos point
        o.on_drag_end.add(g.ON_MOUSE_MOVE_ASYNC.add(function(pos)
            o.on_drag(pos)
        end))
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
            o.on_drag_end()
        end
    )
end
