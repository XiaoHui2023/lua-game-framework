---@type lib.metatablex
local metatable = require "lib.metatablex"
---@type framework.ui
local g = require "..base"

---@param o ui
---@param args ui.options
return function (o,args)
    ---@class ui
    o = o

    ---@type hook.set 浣嶇疆锛堢櫨鍒嗘瘮锛?
    o.relative_position = o.factory.set({x=0.5,y=0.5})

    ---@type hook.set 鍍忕礌浣嶇疆
    o.pixel_position = o.factory.set({x=0,y=0})

    -- 搴旂敤浣嶇疆
    o.pixel_position.on_change.add(function(position)
        g.set_position(o, position.x, position.y)
    end)

    -- 鍖呰鍍忕礌浣嶇疆
    o.pixel_position.wrap_set(function(position)
        position.x = math.floor(position.x)
        position.y = math.floor(position.y)
        return metatable.with_tostring_format(position, "<pixel_position %d,%d>", position.x, position.y)
    end)
    o.pixel_position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)

    -- 鍖呰鐩稿浣嶇疆
    o.relative_position.wrap_set(function(position)
        position.x = (position.x > 1 and 1) or (position.x < 0 and 0) or position.x
        position.y = (position.y > 1 and 1) or (position.y < 0 and 0) or position.y
        -- 淇濈暀灏忔暟鐐瑰悗涓変綅
        position.x = math.floor(position.x * 1000) / 1000
        position.y = math.floor(position.y * 1000) / 1000
        return metatable.with_tostring_format(position, "<relative_position %.3f,%.3f>", position.x, position.y)
    end)
    o.relative_position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)

    -- 鍍忕礌杞浉瀵逛綅缃?
    o.pixel_position.on_change.add(function(position)
        local window_width, window_height = o.window_size()
        local relative_x = position.x / window_width
        local relative_y = position.y / window_height
        o.relative_position.set({x=relative_x, y=relative_y})
    end)

    -- 鐩稿浣嶇疆杞儚绱犱綅缃?
    o.relative_position.on_change.add(function(position)
        local window_width, window_height = o.window_size()
        local pixel_x = window_width * position.x
        local pixel_y = window_height * position.y
        o.pixel_position.set({x=pixel_x, y=pixel_y})
    end)
end
