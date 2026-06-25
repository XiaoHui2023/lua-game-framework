---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

local FLOW_BY_TYPE = {
    horizontal = {
        left_to_right = true,
        right_to_left = true,
    },
    vertical = {
        top_to_bottom = true,
        bottom_to_top = true,
    },
}

---@param api framework.ui.api.CreateContainer 容器创建回调参数
apis.CREATE_CONTAINER(function(api)
    local options_extra = api.options_extra
    local args = api.options
    args = table.merge(args or {}, options_extra)
    args.mode = args.mode or "single"
    args.layout = args.layout or {}
    args.layout.type = args.layout.type or "horizontal"
    args.layout.flow = args.layout.flow or (args.layout.type == "vertical" and "top_to_bottom" or "left_to_right")
    assert(FLOW_BY_TYPE[args.layout.type], "framework.ui.container requires supported layout type")
    assert(FLOW_BY_TYPE[args.layout.type][args.layout.flow], "framework.ui.container layout flow must match layout type")
    args.layout.reverse = args.layout.reverse or false
    args.layout.spacing = args.layout.spacing or 0
    args.layout.padding = args.layout.padding or 0

    local void_api = apis.CREATE_VOID({ options = args })
    assert(void_api.ui ~= nil, "framework.ui.CREATE_CONTAINER requires CREATE_VOID result")
    ---@type framework.ui.container
    local o = void_api.ui
    o.is_content_sized = true

    ---@type reactive.add<framework.ui>
    o.factory.widgets.add({
        ---@param a framework.ui 待排序的前一个子 UI
        ---@param b framework.ui 待排序的后一个子 UI
        ---@return boolean before a 是否排在 b 前面
        compare = function(a, b)
            return a.priority() < b.priority()
        end,
    })

    o.factory.mode.set(args.mode)

    o.layout = {}
    o.layout.type = o.factory.set(args.layout.type)
    o.layout.flow = o.factory.set(args.layout.flow)
    o.layout.reverse = o.factory.set(args.layout.reverse)
    o.layout.spacing = o.factory.set(args.layout.spacing)
    o.layout.padding = o.factory.set(args.layout.padding)

    local widget_removers = {}
    local hidden_widget_unlocks = {}

    local function clear_hidden_widget_locks()
        for widget, unlock in pairs(hidden_widget_unlocks) do
            unlock()
            hidden_widget_unlocks[widget] = nil
        end
    end

    ---@param ui framework.ui 需要加入布局的子 UI
    o.add_child = function(ui)
        if ui.parent and ui.parent() ~= o then
            ui.factory.set_parent(o)
        end
        if not widget_removers[ui] then
            widget_removers[ui] = o.widgets.add(ui)
        end
    end

    ---@param uis framework.ui[] 需要批量加入布局的子 UI 列表
    o.add_children = function(uis)
        for _, ui in ipairs(uis) do
            o.add_child(ui)
        end
    end

    ---@param ui framework.ui 需要从布局移除的子 UI
    o.remove_child = function(ui)
        local remove_widget = widget_removers[ui]
        if remove_widget then
            remove_widget()
            widget_removers[ui] = nil
        end
        if ui.factory and ui.factory.get_parent() == o then
            ui.factory.set_parent(nil)
        end
        local unlock = hidden_widget_unlocks[ui]
        if unlock then
            unlock()
            hidden_widget_unlocks[ui] = nil
        end
    end

    ---@type reactive.computed<framework.ui?>
    local primary_widget = o.factory.computed(function()
        ---@type list<framework.ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return nil
        end
        return widgets.first()
    end)

    local function relative_layout_pixels()
        local spacing = o.layout.spacing()
        local padding = o.layout.padding()
        local window_width, window_height = o.window_size()
        return {
            spacing_x = spacing * window_width,
            spacing_y = spacing * window_height,
            padding_x = padding * window_width,
            padding_y = padding * window_height,
        }
    end

    local function get_single_pixel_size()
        ---@type framework.ui
        local ui = primary_widget()
        return ui.scaled_pixel_size()
    end

    local function get_stack_pixel_size()
        ---@type list<framework.ui>
        local widgets = o.widgets()
        ---@type framework.ui.container.layout.type
        local layout_type = o.layout.type()
        local spacing = relative_layout_pixels()
        local count = widgets.count

        if layout_type == "horizontal" then
            local max_height = 0
            local width_sum = 0
            widgets.for_each(function(widget)
                local width, height = widget.scaled_pixel_size()
                max_height = math.max(max_height, height)
                width_sum = width_sum + width
            end)
            return width_sum + math.max(0, count - 1) * spacing.spacing_x + spacing.padding_x * 2,
                max_height + spacing.padding_y * 2
        elseif layout_type == "vertical" then
            local max_width = 0
            local height_sum = 0
            widgets.for_each(function(widget)
                local width, height = widget.scaled_pixel_size()
                max_width = math.max(max_width, width)
                height_sum = height_sum + height
            end)
            return max_width + spacing.padding_x * 2,
                height_sum + math.max(0, count - 1) * spacing.spacing_y + spacing.padding_y * 2
        else
            error("not implemented")
        end
    end

    o.pixel_size.compute(function()
        ---@type framework.ui.container.mode
        local mode = o.mode()
        ---@type list<framework.ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return 0, 0
        end
        if mode == "single" then
            return get_single_pixel_size()
        elseif mode == "stack" then
            return get_stack_pixel_size()
        else
            error("not implemented")
        end
    end)

    local function layout_single()
        ---@type framework.ui
        local ui = primary_widget()
        ---@type list<framework.ui>
        local widgets = o.widgets()
        clear_hidden_widget_locks()
        if ui == nil then
            return
        end
        widgets.for_each(function(widget)
            if widget ~= ui then
                hidden_widget_unlocks[widget] = widget.hide_lock.acquire()
            end
        end)

        ui.anchor_center(o)
    end

    local function stack_offset(point, layout_type, has_previous, relative_ui)
        local spacing = o.layout.spacing()
        local padding = o.layout.padding()
        local distance = has_previous and spacing or padding
        if distance == 0 then
            return 0, 0
        end
        local window_width, window_height = o.window_size()
        local target_width, target_height = relative_ui.visual_size()
        if layout_type == "horizontal" then
            if target_width == 0 then
                return 0, 0
            end
            local x = distance * window_width / target_width
            return point == "left_center" and x or -x, 0
        elseif layout_type == "vertical" then
            if target_height == 0 then
                return 0, 0
            end
            local y = distance * window_height / target_height
            return 0, point == "top_center" and -y or y
        end
        return 0, 0
    end

    local function layout_stack()
        ---@type list<framework.ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return
        end
        ---@type framework.ui.container.layout.type
        local layout_type = o.layout.type()
        ---@type framework.ui.container.layout.flow
        local flow = o.layout.flow()
        local reverse = o.layout.reverse()
        ---@type framework.ui
        local last

        clear_hidden_widget_locks()
        widgets.for_each(function(widget)
            ---@type framework.ui.position
            local point
            ---@type framework.ui.position
            local relative_point
            ---@type framework.ui
            local relative_ui

            if last then
                if layout_type == "horizontal" then
                    if (flow == "left_to_right" and not reverse) or (flow == "right_to_left" and reverse) then
                        point = "left_center"
                        relative_point = "right_center"
                    elseif (flow == "left_to_right" and reverse) or (flow == "right_to_left" and not reverse) then
                        point = "right_center"
                        relative_point = "left_center"
                    end
                elseif layout_type == "vertical" then
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
                if layout_type == "horizontal" then
                    if (flow == "left_to_right" and not reverse) or (flow == "right_to_left" and reverse) then
                        point = "left_center"
                        relative_point = "left_center"
                    elseif (flow == "left_to_right" and reverse) or (flow == "right_to_left" and not reverse) then
                        point = "right_center"
                        relative_point = "right_center"
                    end
                elseif layout_type == "vertical" then
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

            local x, y = stack_offset(point, layout_type, last ~= nil, relative_ui)
            widget.anchor.set({
                point = point,
                relative_point = relative_point,
                x = x,
                y = y,
                relative_ui = relative_ui,
            })
            last = widget
        end)
    end

    local function refresh_layout()
        ---@type framework.ui.container.mode
        local mode = o.mode()
        if mode == "single" then
            layout_single()
        elseif mode == "stack" then
            layout_stack()
        else
            error("not implemented")
        end
    end

    o.widgets.on_add.add(function(widget)
        o.factory.capture("", widget)
        refresh_layout()
    end)

    o.widgets.on_change.add(function()
        refresh_layout()
    end)

    o.mode.on_change.add(refresh_layout)
    o.layout.type.on_change.add(refresh_layout)
    o.layout.flow.on_change.add(refresh_layout)
    o.layout.reverse.on_change.add(refresh_layout)
    o.layout.spacing.on_change.add(refresh_layout)
    o.layout.padding.on_change.add(refresh_layout)

    api.ui = o
end)

return true
