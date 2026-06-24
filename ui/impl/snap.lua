---@type mathx.geometry
local geometry = require "mathx.geometry"

---@param o framework.ui 要装配吸附能力的 UI 对象
return function (o)
    ---@type framework.ui
    o = o

    ---@type reactive.event 吸附悬浮事件，参数为被吸附 UI
    o.factory.on_snap_hover.event()

    ---@type reactive.event 吸附离开事件，参数为被吸附 UI
    o.factory.on_snap_leave.event()

    ---@type reactive.event 吸附放下事件，参数为被吸附 UI
    o.factory.on_snap_drop.event()

    ---@type reactive.add 吸附
    o.factory.snap.add()

    ---@type framework.ui?
    local snap_ui
    ---@type framework.ui?
    local last_snap_ui

    local function render_drag()
        ---@type framework.ui 最短距离的framework.ui
        local min_ui = nil

        if o.snap.count() > 0 then
            ---@type list 吸附列表
            local list = o.snap()
            ---@type point 当前位置
            local point = o.pixel_position()
            ---@type number 最短距离
            local min_distance = nil

            ---@param target framework.ui 候选吸附目标
            list.for_each(function(target)
                ---@type point 吸附目标位置
                local target_point = target.pixel_position()

                -- 不可见目标不参与吸附。
                if not target.visible() then
                    return
                end

                -- 未接触目标不参与吸附。
                local self_width,self_height = o.visual_size()
                local target_width,target_height = target.visual_size()
                local dx = math.abs(point.x - target_point.x)
                local dy = math.abs(point.y - target_point.y)
                if dx > (target_width+self_width) / 2 or dy > (target_height+self_height) / 2 then
                    return
                end

                -- 选择距离最近的目标。
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
        ---@param target framework.ui 新增的吸附目标
        ---@param delete reactive.once_event 目标移除时的清理事件
        function(target, delete)
            target.delete.mount(delete)
        end
    )
end
