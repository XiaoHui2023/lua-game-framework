---@type models.unit
local g = require "..base"

---@class unit.options
---@field turn_speed? number 转身速度
---@field height? number 高度

---@param o unit
---@param args unit.options
return function (o,args)
    args.turn_speed = args.turn_speed or g.DEFAULT_TURN_SPEED
    args.height = args.height or g.DEFAULT_HEIGHT

    ---@class unit
    o = o
    
    ---@type hook.set 高度
    o.height = o.factory.set(args.height)

    ---@type hook.set 转身速度
    o.turn_speed = o.factory.set(args.turn_speed)

    -- 重载设置转身速度
    o.turn_speed.on_change.add(function(speed)
        g.set_turn_speed(o.handle(), speed)
    end)

    -- 重载设置高度
    o.height.on_change.add(function(height)
        g.set_height(o.handle(), height)
    end)

    -- 重载设置位置
    o.position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)
    o.position.on_change.add(function(position)
        g.set_position(o.handle(), position)
    end)

    -- 重载得到位置
    o.position.override_raw_get(function()
        return g.get_position(o.handle())
    end)

    -- 重载设置朝向
    o.facing.on_change.add(function(facing)
        g.set_facing(o.handle(), facing)
    end)

    -- 重载得到朝向
    o.facing.override_raw_get(function()
        return g.get_facing(o.handle())
    end)
    
    -- 传送
    ---@param position point 位置
    o.teleport = function(position)
        g.teleport(o.handle(), position)
    end
end