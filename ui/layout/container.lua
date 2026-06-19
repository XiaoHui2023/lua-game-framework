---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
local M = require "framework.ui"

---@alias ui.container.mode
---| 'single'
---| 'toggle'
---| 'overlay'
---@alias ui.container.layout.type
---| "horizontal"
---| "vertical"
---| "grid"

---@alias ui.container.layout.flow
---| "top_to_bottom"
---| "bottom_to_top"
---| "left_to_right"
---| "right_to_left"

---@alias ui.container.layout.grid_wrap
---| "row"
---@class ui.container.layout.options
---@field type? ui.container.layout.type 布局排列类型
---@field reverse? boolean 是否反向排列
---@field spacing? number 子控件间距
---@field grid_rows? integer 网格行数
---@field grid_wrap? ui.container.layout.grid_wrap 网格换行方向
---@field grid_spacing? {x:number, y:number} 网格横纵间距

---@class ui.container.options: ui.options
---@field mode? ui.container.mode 容器显示模式
---@field layout? ui.container.layout.options 容器布局配置

-- 容器
---@param args? ui.container.options 容器配置
---@param ... ui.container.options
---@return ui.container
M.container = function(args,...)
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
    ---@field layout ui.container.layout 布局状态
    local o = M.void(args)

    ---@type reactive.add<ui>
    o.widgets = o.factory.add({
        ---@param a ui
        ---@param b ui
        ---@return boolean
        compare = function(a, b)
            return a.priority() < b.priority()
        end,
    })

    ---@type lib.reactive.ref 容器显示模式
    o.mode = o.factory.set(args.mode)

    ---@class ui.container.layout 布局状态
    o.layout = {}

    ---@type lib.reactive.ref 布局排列类型
    o.layout.type = o.factory.set(args.layout.type)

    ---@type lib.reactive.ref
    o.layout.flow = o.factory.set(args.layout.flow)

    ---@type lib.reactive.ref
    o.layout.reverse = o.factory.set(args.layout.reverse)

    ---@type lib.reactive.ref
    o.layout.spacing = o.factory.set(args.layout.spacing)

    ---@type lib.reactive.ref
    o.layout.padding = o.factory.set(args.layout.padding)

    ---@type lib.reactive.ref
    o.layout.grid_columns = o.factory.set(args.layout.grid_columns)
    
    ---@type lib.reactive.ref 网格行数
    o.layout.grid_rows = o.factory.set(args.layout.grid_rows)

    ---@type lib.reactive.ref
    o.layout.grid_wrap = o.factory.set(args.layout.grid_wrap)

    ---@type lib.reactive.ref
    o.layout.grid_spacing = o.factory.set(args.layout.grid_spacing)

    -- 添加子控件
    ---@param ui ui
    o.add_child = function (ui)
        if ui.parent and ui.parent() ~= o then
            ui.parent.set(o)
        end
        o.widgets.add(ui)
    end

    o.add_children = function (uis)
        for _, ui in ipairs(uis) do
           o.add_child(ui) 
        end
    end

    ---@type reactive.computed<ui?>
    local primary_widget = o.factory.computed(function()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return nil
        end
        return widgets.first()
    end)

    ---@type reactive.once_event
    local once_clear_refresh = o.factory.once_event()

    local function get_single_pixel_size()
        ---@type ui
        local ui = primary_widget()
        return ui.scaled_pixel_size()
    end

    local function get_stack_pixel_size()
        ---@type list<ui>
        local widgets = o.widgets()
        ---@type ui.container.layout.type
        local type = o.layout.type()
        
        if type == "horizontal" then
            ---@type number
            local max_height = 0
            ---@type number
            local width_sum = 0
            widgets.for_each(
                ---@param widget ui
                function(widget)
                    local width,height = widget.scaled_pixel_size()
                    if height > max_height then
                        max_height = height
                    end
                    width_sum = width_sum + width
                end
            )
            return width_sum, max_height
        elseif type == "vertical" then
            ---@type number
            local max_width = 0
            ---@type number
            local height_sum = 0
            widgets.for_each(
                ---@param widget ui
                function(widget)
                    local width,height = widget.scaled_pixel_size()
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

    o.pixel_size.compute(function()
        ---@type ui.container.mode
        local mode = o.mode()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return 0,0
        end
        if mode == "single" then
            return get_single_pixel_size()
        elseif mode == "stack" then
            return get_stack_pixel_size()
        else
            error("not implemented")
        end
    end)
    
    --- 单控件布局
    local function layout_single()
        ---@type ui
        local ui = primary_widget()
        ---@type list<ui>
        local widgets = o.widgets()
        if ui == nil then
            return
        end
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

    --- 堆叠布局
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

    o.widgets.on_add.add(
        ---@param widget ui
        function(widget)
            -- 添加子控件
            o.children.add(widget)
            o.factory.capture("", widget)

            once_clear_refresh()

            refresh_layout()
        end
    )

    return o
end

return M
