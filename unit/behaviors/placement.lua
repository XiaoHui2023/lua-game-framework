---@type framework.unit
local M = require "framework.unit"
---@type framework.unit.apis
local apis = require "..apis"

---@class unit.options
---@field turn_speed? number 转身速度
---@field height? number 离地高度

---@param o unit
---@param args unit.options
return function (o,args)
    args.turn_speed = args.turn_speed or M.settings.DEFAULT_TURN_SPEED
    args.height = args.height or M.settings.DEFAULT_HEIGHT

    ---@class unit
    o = o
    
    ---@type hook.set 高度
    o.factory.ref_field("height", args.height)

    ---@type hook.set 转身速度
    o.factory.ref_field("turn_speed", args.turn_speed)

    -- 传送单位到指定位置
    o.turn_speed.on_change.add(function(speed)
        apis.SET_TURN_SPEED({ handle = o.handle(), speed = speed })
    end)

    -- 传送单位到指定位置
    o.height.on_change.add(function(height)
        apis.SET_HEIGHT({ handle = o.handle(), height = height })
    end)

    -- 传送单位到指定位置
    o.position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)
    o.position.on_change.add(function(position)
        apis.SET_POSITION({ handle = o.handle(), position = position })
    end)

    -- 传送单位到指定位置
    o.position.override_raw_get(function()
        local api = apis.GET_POSITION({ handle = o.handle() })
        return api.position
    end)

    -- 传送单位到指定位置
    o.facing.on_change.add(function(facing)
        apis.SET_FACING({ handle = o.handle(), facing = facing })
    end)

    -- 传送单位到指定位置
    o.facing.override_raw_get(function()
        local api = apis.GET_FACING({ handle = o.handle() })
        return api.facing
    end)
    
    -- 传送单位到指定位置
    ---@param position point 目标位置
    o.teleport = function(position)
        apis.TELEPORT({ handle = o.handle(), position = position })
    end
end
