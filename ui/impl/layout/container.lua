---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
local length = require "framework.ui.impl.core.length"

local DEFAULT_LAYOUT = {
    type = "overlay",
    direction = "horizontal",
    gap = 0,
    padding = 0,
    align = "center",
    justify = "start",
}

local function normalize_layout(layout)
    layout = table.merge(DEFAULT_LAYOUT, layout or {})
    layout.padding = length.normalize_padding(layout.padding)
    layout.gap = layout.gap or 0
    layout.align = layout.align or "center"
    layout.justify = layout.justify or "start"
    layout.direction = layout.direction or "horizontal"
    assert(layout.type == "none" or layout.type == "overlay" or layout.type == "stack", "unsupported container layout")
    assert(layout.direction == "horizontal" or layout.direction == "vertical", "unsupported stack direction")
    return layout
end

local function get_child_constraints(size, padding)
    return {
        min_width = 0,
        max_width = math.max(0, size.width - padding.left - padding.right),
        min_height = 0,
        max_height = math.max(0, size.height - padding.top - padding.bottom),
    }
end

---@param api framework.ui.api.CreateContainer
apis.CREATE_CONTAINER(function(api)
    local args = table.merge(api.options or {}, api.options_extra)
    args.layout = normalize_layout(args.layout)

    local void_api = apis.CREATE_VOID({ options = args })
    assert(void_api.ui ~= nil, "framework.ui.CREATE_CONTAINER requires CREATE_VOID result")
    ---@type framework.ui.container
    local o = void_api.ui

    ---@type reactive.add<framework.ui>
    o.factory.collection_field("widgets", {
        compare = function(a, b)
            return a.priority() < b.priority()
        end,
    })

    o.layout = {
        type = o.factory.ref_field("layout_type", args.layout.type),
        direction = o.factory.ref_field("layout_direction", args.layout.direction),
        gap = o.factory.ref_field("layout_gap", args.layout.gap),
        padding = o.factory.ref_field("layout_padding", args.layout.padding),
        align = o.factory.ref_field("layout_align", args.layout.align),
        justify = o.factory.ref_field("layout_justify", args.layout.justify),
    }

    local widget_removers = {}
    local hidden_widget_unlocks = {}
    local refreshing_layout = false
    local pending_layout_refresh = false
    local measuring_content = false

    local function clear_hidden_widget_locks()
        for widget, unlock in pairs(hidden_widget_unlocks) do
            unlock()
            hidden_widget_unlocks[widget] = nil
        end
    end

    local function get_widgets()
        return o.widgets()
    end

    local function measure_overlay()
        local max_width, max_height = 0, 0
        get_widgets().for_each(function(widget)
            local size = widget.measured_size()
            max_width = math.max(max_width, size.width)
            max_height = math.max(max_height, size.height)
        end)
        local padding = o.layout.padding()
        return {
            width = max_width + padding.left + padding.right,
            height = max_height + padding.top + padding.bottom,
        }
    end

    local function measure_stack()
        local direction = o.layout.direction()
        local gap = o.layout.gap()
        local count = get_widgets().count
        local main, cross = 0, 0
        get_widgets().for_each(function(widget)
            local size = widget.measured_size()
            if direction == "horizontal" then
                main = main + size.width
                cross = math.max(cross, size.height)
            else
                main = main + size.height
                cross = math.max(cross, size.width)
            end
        end)
        main = main + math.max(0, count - 1) * gap

        local padding = o.layout.padding()
        if direction == "horizontal" then
            return {
                width = main + padding.left + padding.right,
                height = cross + padding.top + padding.bottom,
            }
        end
        return {
            width = cross + padding.left + padding.right,
            height = main + padding.top + padding.bottom,
        }
    end

    local function measure_content_size()
        local layout_type = o.layout.type()
        if layout_type == "stack" then
            return measure_stack()
        end
        if layout_type == "none" then
            return { width = 0, height = 0 }
        end
        return measure_overlay()
    end

    o.content_size.compute(function()
        measuring_content = true
        local ok, size = xpcall(measure_content_size, debug.traceback)
        measuring_content = false
        if not ok then
            error(size, 0)
        end
        return size
    end)

    local function set_child_constraints()
        local size = o.measured_size()
        local padding = o.layout.padding()
        local constraints = get_child_constraints(size, padding)
        get_widgets().for_each(function(widget)
            widget.constraints.set(constraints)
        end)
    end

    local function layout_overlay()
        clear_hidden_widget_locks()
        local size = o.measured_size()
        local position = o.pixel_position()
        get_widgets().for_each(function(widget)
            widget.pixel_position.set({ x = position.x, y = position.y })
            widget.layout_rect.set(length.rect(position.x, position.y, size.width, size.height))
        end)
    end

    local function layout_stack()
        clear_hidden_widget_locks()
        local size = o.measured_size()
        local position = o.pixel_position()
        local padding = o.layout.padding()
        local direction = o.layout.direction()
        local gap = o.layout.gap()
        local x = position.x - size.width / 2 + padding.left
        local y = position.y + size.height / 2 - padding.top

        get_widgets().for_each(function(widget)
            local child_size = widget.measured_size()
            if direction == "horizontal" then
                local child_x = x + child_size.width / 2
                widget.pixel_position.set({ x = child_x, y = position.y })
                widget.layout_rect.set(length.rect(child_x, position.y, child_size.width, child_size.height))
                x = x + child_size.width + gap
            else
                local child_y = y - child_size.height / 2
                widget.pixel_position.set({ x = position.x, y = child_y })
                widget.layout_rect.set(length.rect(position.x, child_y, child_size.width, child_size.height))
                y = y - child_size.height - gap
            end
        end)
    end

    local function do_refresh_layout()
        set_child_constraints()
        local layout_type = o.layout.type()
        if layout_type == "stack" then
            layout_stack()
        elseif layout_type == "overlay" then
            layout_overlay()
        end
    end

    local function refresh_layout()
        if measuring_content then
            pending_layout_refresh = true
            return
        end
        if refreshing_layout then
            pending_layout_refresh = true
            return
        end

        refreshing_layout = true
        local ok, err = xpcall(function()
            repeat
                pending_layout_refresh = false
                do_refresh_layout()
            until not pending_layout_refresh
        end, debug.traceback)
        refreshing_layout = false
        if not ok then
            error(err, 0)
        end
    end

    local function add_widget(ui)
        if not widget_removers[ui] then
            widget_removers[ui] = o.widgets.add(ui)
            ui.measured_size.on_change.add(refresh_layout)
        end
        refresh_layout()
    end

    local function remove_widget(ui)
        local remove_widget = widget_removers[ui]
        if remove_widget then
            remove_widget()
            widget_removers[ui] = nil
        end
        local unlock = hidden_widget_unlocks[ui]
        if unlock then
            unlock()
            hidden_widget_unlocks[ui] = nil
        end
        refresh_layout()
    end

    o.widgets.on_change.add(refresh_layout)
    o.measured_size.on_change.add(refresh_layout)
    o.pixel_position.on_change.add(refresh_layout)
    o.layout.type.on_change.add(refresh_layout)
    o.layout.direction.on_change.add(refresh_layout)
    o.layout.gap.on_change.add(refresh_layout)
    o.layout.padding.on_change.add(refresh_layout)
    o.layout.align.on_change.add(refresh_layout)
    o.layout.justify.on_change.add(refresh_layout)

    o.factory.on_add_child.add(add_widget)
    o.factory.on_remove_child.add(remove_widget)

    api.ui = o
end)

return true
