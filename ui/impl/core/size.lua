---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
local length = require "framework.ui.impl.core.length"

---@param o framework.ui
---@param args framework.ui.object_config
return function(o, args)
    args = args or {}

    local window_size_api = apis.GET_WINDOW_SIZE({})
    assert(window_size_api.width ~= nil, "framework.ui.size requires runtime backend width")
    assert(window_size_api.height ~= nil, "framework.ui.size requires runtime backend height")

    local initial_constraints = {
        min_width = 0,
        max_width = window_size_api.width,
        min_height = 0,
        max_height = window_size_api.height,
    }

    o.factory.ref_field("window_size", {
        width = window_size_api.width,
        height = window_size_api.height,
    })
    o.factory.ref_field("size_spec", length.normalize_size_spec(args.size))
    o.factory.ref_field("constraints", initial_constraints)
    o.factory.ref_field("layout_rect", length.rect(0, 0, 0, 0))
    o.factory.ref_field("visual_scale", args.visual_scale or 1)
    o.factory.ref_field("layout_scale", args.layout_scale or 1)

    if o.relative_position and o.pixel_position then
        local position = o.relative_position()
        o.pixel_position.set({
            x = window_size_api.width * position.x,
            y = window_size_api.height * position.y,
        })
    end

    o.factory.computed_field("content_size", function()
        return { width = 0, height = 0 }
    end)

    o.factory.computed_field("measured_size", function()
        local size = length.resolve_size(o.size_spec(), o.constraints(), o.content_size())
        local scale = o.layout_scale()
        return {
            width = math.floor(size.width * scale + 0.5),
            height = math.floor(size.height * scale + 0.5),
        }
    end)

    o.factory.computed_field("render_rect", function()
        local position = o.pixel_position()
        local size = o.measured_size()
        local scale = settings.UI_APPLICATION_SIZE_SCALE * o.visual_scale()
        return length.rect(
            position.x,
            position.y,
            math.floor(size.width * scale + 0.5),
            math.floor(size.height * scale + 0.5)
        )
    end)

    o.factory.computed_field("visual_size", function()
        local rect = o.render_rect()
        return rect.width, rect.height
    end)

    o.size_spec.wrap_set(function(value)
        return length.normalize_size_spec(value)
    end)
    o.size_spec.wrap_equal(function(value, old_value)
        return old_value
            and value.width == old_value.width
            and value.height == old_value.height
            and value.min_width == old_value.min_width
            and value.min_height == old_value.min_height
            and value.max_width == old_value.max_width
            and value.max_height == old_value.max_height
            and value.aspect_ratio == old_value.aspect_ratio
    end)

    o.constraints.wrap_set(function(value)
        return length.normalize_constraints(value)
    end)
    o.constraints.wrap_equal(function(value, old_value)
        return old_value
            and value.min_width == old_value.min_width
            and value.max_width == old_value.max_width
            and value.min_height == old_value.min_height
            and value.max_height == old_value.max_height
    end)

    o.layout_rect.wrap_set(function(value)
        value = length.copy_rect(value)
        value.x = math.floor(value.x + 0.5)
        value.y = math.floor(value.y + 0.5)
        value.width = math.floor(value.width + 0.5)
        value.height = math.floor(value.height + 0.5)
        return value
    end)
    o.layout_rect.wrap_equal(length.same_rect)

    o.render_rect.on_change.add(function(rect)
        apis.SET_SIZE({ ui = o, width = rect.width, height = rect.height })
        apis.SET_POSITION({ ui = o, x = rect.x, y = rect.y })
    end)

    o.factory.delete.add(apis.ON_WINDOW_SIZE_CHANGE(function(api)
        o.window_size.set({ width = api.width, height = api.height })
        o.constraints.set({
            min_width = 0,
            max_width = api.width,
            min_height = 0,
            max_height = api.height,
        })
        if o.relative_position and o.pixel_position then
            local position = o.relative_position()
            o.pixel_position.set({
                x = api.width * position.x,
                y = api.height * position.y,
            })
        end
    end))

    o.render_rect.auto_update()
end
