---@type framework.unit
local M = require "..base"

---@class unit.options
---@field turn_speed? number 字段说明
---@field height? number 字段说明

---@param o unit
---@param args unit.options
return function (o,args)
    args.turn_speed = args.turn_speed or M.DEFAULT_TURN_SPEED
    args.height = args.height or M.DEFAULT_HEIGHT

    ---@class unit
    o = o
    
    ---@type hook.set 高度
    o.height = o.factory.set(args.height)

    ---@type hook.set 转身速度
    o.turn_speed = o.factory.set(args.turn_speed)

    -- 重载设置转身速度
    o.turn_speed.on_change.add(function(speed)
        M.set_turn_speed(o.handle(), speed)
    end)

    -- 重载设置高度
    o.height.on_change.add(function(height)
        M.set_height(o.handle(), height)
    end)

    -- 重载设置位置
    o.position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)
    o.position.on_change.add(function(position)
        M.set_position(o.handle(), position)
    end)

    -- 重载得到位置
    o.position.override_raw_get(function()
        return M.get_position(o.handle())
    end)

    -- 重载设置朝向
    o.facing.on_change.add(function(facing)
        M.set_facing(o.handle(), facing)
    end)

    -- 重载得到朝向
    o.facing.override_raw_get(function()
        return M.get_facing(o.handle())
    end)
    
    -- 传送
    ---@param position point 位置
    o.teleport = function(position)
        M.teleport(o.handle(), position)
    end
end
