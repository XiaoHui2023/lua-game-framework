---@type framework.unit
local M = require "framework.unit"
---@type framework.unit.apis
local apis = require "..apis"

---@class unit.options
---@field move_speed? number 字段说明
---@field base_attack_speed? number 字段说明
---@field attack_speed? number 字段说明
---@field attack_range? number 字段说明

---@param o unit
---@param args unit.options
return function (o,args)
    args.move_speed = args.move_speed or M.settings.DEFAULT_MOVE_SPEED
    args.base_attack_speed = args.base_attack_speed or M.settings.DEFAULT_BASE_ATTACK_SPEED
    args.attack_speed = args.attack_speed or M.settings.DEFAULT_ATTACK_SPEED
    args.attack_range = args.attack_range or M.settings.DEFAULT_ATTACK_RANGE
    
    ---@class unit
    o = o

    ---@type hook.set 移动速度
    o.move_speed = o.factory.set(args.move_speed)
    ---@type hook.set 基础攻击速度
    o.base_attack_speed = o.factory.set(args.base_attack_speed)
    ---@type hook.set 攻击速度
    o.attack_speed = o.factory.set(args.attack_speed)
    ---@type hook.set 攻击范围
    o.attack_range = o.factory.set(args.attack_range)

    -- 重载设置移动速度
    o.move_speed.on_change.add(function(speed)
        apis.SET_MOVE_SPEED({ handle = o.handle(), speed = speed })
    end)

    -- 重载设置攻击速度
    o.attack_speed.on_change.add(function(speed)
        local real_speed = 1 / (speed * o.base_attack_speed())
        apis.SET_ATTACK_INTERVAL({ handle = o.handle(), interval = real_speed })
    end)

    -- 重载设置攻击范围
    o.attack_range.on_change.add(function(range)
        apis.SET_ATTACK_RANGE({ handle = o.handle(), range = range })
    end)
end
