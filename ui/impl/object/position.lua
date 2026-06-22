---@type lib.metatablex
local metatable = require "lib.metatablex"
---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o framework.ui 要装配位置能力的 UI 对象
---@param args framework.ui.options UI 创建参数
return function (o,args)
    ---@class framework.ui
    o = o

    ---@type lib.reactive.ref
    o.factory.relative_position.set({x=0.5,y=0.5})

    ---@type lib.reactive.ref
    o.factory.pixel_position.set({x=0,y=0})

    local is_syncing_position = false

    -- 应用位置
    o.pixel_position.on_change.add(function(position)
        apis.SET_POSITION({ ui = o, x = position.x, y = position.y })
    end)

    o.pixel_position.wrap_set(function(position)
        position.x = math.floor(position.x + 0.5)
        position.y = math.floor(position.y + 0.5)
        return metatable.with_tostring_format(position, "<pixel_position %d,%d>", position.x, position.y)
    end)
    o.pixel_position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)

    o.relative_position.wrap_set(function(position)
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
        if is_syncing_position then
            return
        end
        local window_width, window_height = o.window_size()
        local relative_x = position.x / window_width
        local relative_y = position.y / window_height
        is_syncing_position = true
        o.relative_position.set({x=relative_x, y=relative_y})
        is_syncing_position = false
    end)

    o.relative_position.on_change.add(function(position)
        if is_syncing_position then
            return
        end
        local window_width, window_height = o.window_size()
        local pixel_x = window_width * position.x
        local pixel_y = window_height * position.y
        is_syncing_position = true
        o.pixel_position.set({x=pixel_x, y=pixel_y})
        is_syncing_position = false
    end)
end
