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
---@field type? ui.container.layout.type
---@field reverse? boolean
---@field spacing? number
---@field padding? number
---@field grid_columns? integer
---@field grid_rows? integer
---@field grid_wrap? ui.container.layout.grid_wrap
---@field grid_spacing? {x:number, y:number}

---@class ui.container.options: ui.options
---@field mode? ui.container.mode
---@field layout? ui.container.layout.options

---@param args? ui.container.options
---@param ... ui.container.options
---@return ui.container
M.container = function(args, ...)
    args = table.merge(args or {}, ...)
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
    args.layout.grid_spacing = args.layout.grid_spacing or { x = 0, y = 0 }

    ---@class ui.container: ui.void
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

    o.mode = o.factory.set(args.mode)

    ---@class ui.container.layout
    o.layout = {}
    o.layout.type = o.factory.set(args.layout.type)
    o.layout.flow = o.factory.set(args.layout.flow)
    o.layout.reverse = o.factory.set(args.layout.reverse)
    o.layout.spacing = o.factory.set(args.layout.spacing)
    o.layout.padding = o.factory.set(args.layout.padding)
    o.layout.grid_columns = o.factory.set(args.layout.grid_columns)
    o.layout.grid_rows = o.factory.set(args.layout.grid_rows)
    o.layout.grid_wrap = o.factory.set(args.layout.grid_wrap)
    o.layout.grid_spacing = o.factory.set(args.layout.grid_spacing)

    local widget_removers = {}
    local hidden_widget_unlocks = {}

    local function clear_hidden_widget_locks()
        for widget, unlock in pairs(hidden_widget_unlocks) do
            unlock()
            hidden_widget_unlocks[widget] = nil
        end
    end

    ---@param ui ui
    o.add_child = function(ui)
        if ui.parent and ui.parent() ~= o then
            if ui.set_parent then
                ui.set_parent(o)
            else
                ui.parent.set(o)
            end
        end
        if not widget_removers[ui] then
            widget_removers[ui] = o.widgets.add(ui)
        end
    end

    ---@param uis ui[]
    o.add_children = function(uis)
        for _, ui in ipairs(uis) do
            o.add_child(ui)
        end
    end

    ---@param ui ui
    o.remove_child = function(ui)
        local remove_widget = widget_removers[ui]
        if remove_widget then
            remove_widget()
            widget_removers[ui] = nil
        end
        if o.detach_child then
            o.detach_child(ui)
        end
        local unlock = hidden_widget_unlocks[ui]
        if unlock then
            unlock()
            hidden_widget_unlocks[ui] = nil
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
        ---@type ui
        local ui = primary_widget()
        return ui.scaled_pixel_size()
    end

    local function get_stack_pixel_size()
        ---@type list<ui>
        local widgets = o.widgets()
        ---@type ui.container.layout.type
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
        ---@type ui.container.mode
        local mode = o.mode()
        ---@type list<ui>
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
        ---@type ui
        local ui = primary_widget()
        ---@type list<ui>
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

    local function stack_offset(point, layout_type, has_previous)
        local spacing = o.layout.spacing()
        local padding = o.layout.padding()
        local distance = has_previous and spacing or padding
        if distance == 0 then
            return 0, 0
        end
        if layout_type == "horizontal" then
            return point == "left_center" and distance or -distance, 0
        elseif layout_type == "vertical" then
            return 0, point == "top_center" and -distance or distance
        end
        return 0, 0
    end

    local function layout_stack()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return
        end
        ---@type ui.container.layout.type
        local layout_type = o.layout.type()
        ---@type ui.container.layout.flow
        local flow = o.layout.flow()
        local reverse = o.layout.reverse()
        ---@type ui
        local last

        clear_hidden_widget_locks()
        widgets.for_each(function(widget)
            ---@type ui.position
            local point
            ---@type ui.position
            local relative_point
            ---@type ui
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

            local x, y = stack_offset(point, layout_type, last ~= nil)
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

    o.widgets.on_add.add(function(widget)
        if o.attach_child then
            o.attach_child(widget)
        else
            o.children.add(widget)
        end
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

    return o
end

return M
