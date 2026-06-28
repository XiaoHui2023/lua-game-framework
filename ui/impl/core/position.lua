---@type lib.metatablex
local metatable = require "lib.metatablex"

---@param o framework.ui
---@param args framework.ui.object_config
return function(o, args)
    o = o
    args = args or {}

    local initial_position = args.position or { x = 0.5, y = 0.5 }
    o.factory.ref_field("relative_position", initial_position)
    o.factory.ref_field("pixel_position", { x = 0, y = 0 })
    o.factory.ref_field("is_layout_managed", false)

    local is_syncing_position = false

    o.pixel_position.wrap_set(function(position)
        position = position or {}
        position.x = math.floor((position.x or 0) + 0.5)
        position.y = math.floor((position.y or 0) + 0.5)
        return metatable.with_tostring_format(position, "<pixel_position %d,%d>", position.x, position.y)
    end)
    o.pixel_position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)

    o.relative_position.wrap_set(function(position)
        position = position or {}
        position.x = (position.x or 0)
        position.y = (position.y or 0)
        position.x = (position.x > 1 and 1) or (position.x < 0 and 0) or position.x
        position.y = (position.y > 1 and 1) or (position.y < 0 and 0) or position.y
        position.x = math.floor(position.x * 1000) / 1000
        position.y = math.floor(position.y * 1000) / 1000
        return metatable.with_tostring_format(position, "<relative_position %.3f,%.3f>", position.x, position.y)
    end)
    o.relative_position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)

    o.pixel_position.on_change.add(function(position)
        if is_syncing_position or not o.window_size then
            return
        end
        local window_size = o.window_size()
        if window_size.width == 0 or window_size.height == 0 then
            return
        end
        is_syncing_position = true
        o.relative_position.set({
            x = position.x / window_size.width,
            y = position.y / window_size.height,
        })
        is_syncing_position = false
    end)

    o.relative_position.on_change.add(function(position)
        if is_syncing_position or not o.window_size then
            return
        end
        local window_size = o.window_size()
        is_syncing_position = true
        o.pixel_position.set({
            x = window_size.width * position.x,
            y = window_size.height * position.y,
        })
        is_syncing_position = false
    end)
end
