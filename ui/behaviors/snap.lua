---@type framework.ui
local g = require "..base"
---@type mathx.geometry
local geometry = require "mathx.geometry"

---@param o ui
return function (o)
    ---@class ui
    o = o

    ---@type hook.event 吸附悬浮事件（吸附物：ui）
    o.on_snap_hover = o.factory.event()

    ---@type hook.event 吸附离开事件（吸附物：ui）
    o.on_snap_leave = o.factory.event()

    ---@type hook.event 吸附放下事件（吸附物：ui）
    o.on_snap_drop = o.factory.event()

    ---@type hook.add 吸附
    o.snap = o.factory.add()

    ---@type ui? 当前吸附ui
    local snap_ui
    ---@type ui? 上一次吸附ui
    local last_snap_ui

    local function render_drag()
        ---@type ui 最短距离的ui
        local min_ui = nil

        if o.snap.count() > 0 then
            ---@type list 吸附列表
            local list = o.snap()
            ---@type point 当前位置
            local point = o.pixel_position()
            ---@type number 最短距离
            local min_distance = nil

            ---@param target ui
            list.for_each(function(target)
                ---@type point 吸附物位置
                local target_point = target.pixel_position()

                -- 需要可见
                if not target.visible() then
                    return
                end

                -- 需要接触
                local self_width,self_height = o.total_scaled_pixel_size()
                local target_width,target_height = target.total_scaled_pixel_size()
                local dx = math.abs(point.x - target_point.x)
                local dy = math.abs(point.y - target_point.y)
                if dx > (target_width+self_width) / 2 or dy > (target_height+self_height) / 2 then
                    return
                end

                -- 匹配最短距离
                local distance = geometry.distance(point, target_point)
                if not min_distance or distance < min_distance then
                    min_distance = distance
                    min_ui = target
                end
            end)
        end

        -- 设置
        last_snap_ui = snap_ui
        snap_ui = min_ui

        if snap_ui ~= last_snap_ui then
            if snap_ui ~= nil then
                snap_ui.on_snap_hover(o)
            end
            if last_snap_ui ~= nil then
                last_snap_ui.on_snap_leave(o)
            end
        end
    end

    local function render_drop()
        if snap_ui == nil then
            return
        end
        snap_ui.on_snap_drop(o)

        -- 清除
        snap_ui = nil
    end

    o.on_drag.add(function(pos)
        -- 设置位置
        o.relative_position.set(pos)

        -- 渲染
        render_drag()
    end)

    o.on_drag_end.add(function()
        render_drop()
    end)

    o.snap.on_add.add(
        ---@param target ui
        ---@param delete hook.once_event
        function(target, delete)
            target.delete.mount(delete)
        end
    )
end
