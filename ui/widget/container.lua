---@class models.ui
local g = require "..base"

---@alias ui.container.mode
---| 'single' 只显示优先级最高的一个控件
---| 'stack' 全部控件都可见，按照顺序/布局排开
---| 'toggle' 槽位内可以切换当前激活的控件
---| 'overlay' 所有控件都显示，但按层级叠加

---@alias ui.container.layout.type
---| "horizontal"  -- 水平排列
---| "vertical"    -- 垂直排列
---| "grid"        -- 网格排列

---@alias ui.container.layout.flow
---| "top_to_bottom"  -- 从上到下
---| "bottom_to_top"  -- 从下到上
---| "left_to_right"  -- 从左到右
---| "right_to_left"  -- 从右到左

---@alias ui.container.layout.grid_wrap
---| "row"  -- 行优先
---| "column"  -- 列优先

---@class ui.container.layout.options
---@field type? ui.container.layout.type 当前使用的布局类型（horizontal / vertical / grid）
---@field flow? ui.container.layout.flow 排列方向（horizontal/vertical 时生效）
---@field reverse? boolean 是否反向排列（等价于 flow 的快捷用法）
---@field spacing? number 控件之间的间距
---@field padding? number 外边距
---@field grid_columns? integer 网格列数
---@field grid_rows? integer 网格行数
---@field grid_wrap? ui.container.layout.grid_wrap 网格换行方式（行优先 / 列优先）
---@field grid_spacing? {x:number, y:number} 网格横纵间距

---@class ui.container.options: ui.options
---@field mode? ui.container.mode 模式
---@field layout? ui.container.layout.options 布局

-- 容器
---@param args? ui.container.options
---@param ... ui.container.options
---@return ui.container
g.container = function(args,...)
    args = args or {}
    args = table.merge(args, ...)
    args.mode = args.mode or "single"
    args.layout = args.layout or {}
    args.layout.type = args.layout.type or "horizontal"
    args.layout.flow = args.layout.flow or (args.layout.type == "vertical" and "top_to_bottom" or "left_to_right")
    args.layout.reverse = args.layout.reverse or false
    args.layout.spacing = args.layout.spacing or 0
    args.layout.padding = args.layout.padding or 0
    args.layout.grid_columns = args.layout.grid_columns or 1
    args.layout.grid_rows = args.layout.grid_rows or 1
    args.layout.grid_wrap = args.layout.grid_wrap or "row"
    args.layout.grid_spacing = args.layout.grid_spacing or {x = 0, y = 0}

    ---@class ui.container: ui.void
    ---@field layout ui.container.layout 布局
    local o = g.void(args)

    ---@type hook.add<ui> 控件
    o.widgets = o.factory.add({
        ---@param a ui
        ---@param b ui
        ---@return boolean
        compare = function(a, b)
            return a.priority() < b.priority()
        end,
    })

    ---@type hook.set<ui.container.mode> 模式
    o.mode = o.factory.set(args.mode)

    ---@class ui.container.layout 布局
    o.layout = {}

    ---@type hook.set<ui.container.layout.type> 布局类型
    o.layout.type = o.factory.set(args.layout.type)

    ---@type hook.set<ui.container.layout.flow> 排列方向
    o.layout.flow = o.factory.set(args.layout.flow)

    ---@type hook.set<boolean> 是否反向排列
    o.layout.reverse = o.factory.set(args.layout.reverse)

    ---@type hook.set<number> 控件之间的间距
    o.layout.spacing = o.factory.set(args.layout.spacing)

    ---@type hook.set<number> 外边距
    o.layout.padding = o.factory.set(args.layout.padding)

    ---@type hook.set<integer> 网格列数
    o.layout.grid_columns = o.factory.set(args.layout.grid_columns)
    
    ---@type hook.set<integer> 网格行数
    o.layout.grid_rows = o.factory.set(args.layout.grid_rows)

    ---@type hook.set<ui.container.layout.grid_wrap> 网格换行方式
    o.layout.grid_wrap = o.factory.set(args.layout.grid_wrap)

    ---@type hook.set<{x:number, y:number}> 网格横纵间距
    o.layout.grid_spacing = o.factory.set(args.layout.grid_spacing)

    -- 添加下级
    ---@param ui ui
    o.add_child = function (ui)
        o.widgets.add(ui)
    end

    -- 按列表顺序添加下级
    ---@param uis ui[]
    o.add_children = function (uis)
        for _, ui in ipairs(uis) do
           o.add_child(ui) 
        end
    end

    ---@type hook.computed<ui?> 优先级最高的控件
    local primary_widget = o.factory.computed(function()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return nil
        end
        return widgets.first()
    end)

    ---@type hook.once_event 清除刷新事件 
    local once_clear_refresh = o.factory.once_event()

    -- 得到single视觉大小
    local function get_single_visual_size()
        ---@type ui
        local ui = primary_widget()
        return ui.visual_size()
    end

    -- 得到stack视觉大小
    local function get_stack_visual_size()
        ---@type list<ui>
        local widgets = o.widgets()
        ---@type ui.container.layout.type
        local type = o.layout.type()
        
        if type == "horizontal" then
            ---@type number 最大高度
            local max_height = 0
            ---@type number 宽度总和
            local width_sum = 0
            widgets.for_each(
                ---@param widget ui
                function(widget)
                    local width,height = widget.visual_size()
                    if height > max_height then
                        max_height = height
                    end
                    width_sum = width_sum + width
                end
            )
            return width_sum, max_height
        elseif type == "vertical" then
            ---@type number 最大宽度
            local max_width = 0
            ---@type number 高度总和
            local height_sum = 0
            widgets.for_each(
                ---@param widget ui
                function(widget)
                    local width,height = widget.visual_size()
                    if width > max_width then
                        max_width = width
                    end
                    height_sum = height_sum + height
                end
            )
            return max_width, height_sum
        else
            error("not implemented")
        end
    end

    -- 设置像素大小
    o.pixel_size.compute(function()
        ---@type ui.container.mode
        local mode = o.mode()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return 0,0
        end
        if mode == "single" then
            return get_single_visual_size()
        elseif mode == "stack" then
            return get_stack_visual_size()
        else
            error("not implemented")
        end
    end)
    
    --- single布局
    local function layout_single()
        ---@type ui
        local ui = primary_widget()
        ---@type list<ui>
        local widgets = o.widgets()
        if ui == nil then
            return
        end
        -- 只显示一个
        widgets.for_each(
            ---@param widget ui
            function(widget)
                if widget == ui then
                    return
                end
                once_clear_refresh(widget.hide_lock.acquire()) -- 获取隐藏锁
            end
        )

        ui.anchor_center(o)
    end

    --- stack布局
    local function layout_stack()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return
        end
        ---@type ui.container.layout.type
        local type = o.layout.type()
        ---@type ui.container.layout.flow
        local flow = o.layout.flow()
        ---@type boolean
        local reverse = o.layout.reverse()

        ---@type ui
        local last

        widgets.for_each(
            ---@param widget ui
            function(widget)
                ---@type ui.position
                local point
                ---@type ui.position
                local relative_point
                ---@type ui
                local relative_ui

                if last then
                    if type == "horizontal" then
                        if (flow == "left_to_right" and not reverse) or (flow == "right_to_left" and reverse) then
                            point = "left_center"
                            relative_point = "right_center"
                        elseif (flow == "left_to_right" and reverse) or (flow == "right_to_left" and not reverse) then
                            point = "right_center"
                            relative_point = "left_center"
                        end
                    elseif type == "vertical" then
                        if (flow == "top_to_bottom" and not reverse) or (flow == "bottom_to_top" and reverse) then
                            point = "top_center"
                            relative_point = "bottom_center"
                        elseif (flow == "top_to_bottom" and reverse) or (flow == "bottom_to_top" and not reverse) then
                            point = "bottom_center"
                            relative_point = "top_center"
                        end
                    end
                    relative_ui = last
                else
                    if type == "horizontal" then
                        if (flow == "left_to_right" and not reverse) or (flow == "right_to_left" and reverse) then
                            point = "left_center"
                            relative_point = "left_center"
                        elseif (flow == "left_to_right" and reverse) or (flow == "right_to_left" and not reverse) then
                            point = "right_center"
                            relative_point = "right_center"
                        end
                    elseif type == "vertical" then
                        if (flow == "top_to_bottom" and not reverse) or (flow == "bottom_to_top" and reverse) then
                            point = "top_center"
                            relative_point = "top_center"
                        elseif (flow == "top_to_bottom" and reverse) or (flow == "bottom_to_top" and not reverse) then
                            point = "bottom_center"
                            relative_point = "bottom_center"
                        end
                    end
                    relative_ui = o
                end
                widget.anchor.set({
                    point = point,
                    relative_point = relative_point,
                    x = 0,
                    y = 0,
                    relative_ui = relative_ui,
                })
                last = widget
            end
        )
    end

    --- 刷新布局
    local function refresh_layout()
        ---@type ui.container.mode
        local mode = o.mode()
        if mode == "single" then
            layout_single()
        elseif mode == "stack" then
            layout_stack()
        else
            error("not implemented")
        end
    end

    -- 重载添加控件
    o.widgets.on_add.add(
        ---@param widget ui
        function(widget)
            -- 添加下级
            o.children.add(widget)

            -- 触发清除刷新事件
            once_clear_refresh()

            -- 刷新布局
            refresh_layout()
        end
    )

    return o
end

return g
