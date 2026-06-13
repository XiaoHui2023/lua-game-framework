---@type models.unit
local g = require "..base"

---@class unit.options
---@field move_speed? number 移动速度
---@field base_attack_speed? number 基础攻击速度
---@field attack_speed? number 攻击速度
---@field attack_range? number 攻击范围

---@param o unit
---@param args unit.options
return function (o,args)
    args.move_speed = args.move_speed or g.DEFAULT_MOVE_SPEED
    args.base_attack_speed = args.base_attack_speed or g.DEFAULT_BASE_ATTACK_SPEED
    args.attack_speed = args.attack_speed or g.DEFAULT_ATTACK_SPEED
    args.attack_range = args.attack_range or g.DEFAULT_ATTACK_RANGE
    
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
        g.set_move_speed(o.handle(), speed)
    end)

    -- 重载设置攻击速度
    o.attack_speed.on_change.add(function(speed)
        local real_speed = 1 / (speed * o.base_attack_speed())
        g.set_attack_interval(o.handle(), real_speed)
    end)

    -- 重载设置攻击范围
    o.attack_range.on_change.add(function(range)
        g.set_attack_range(o.handle(), range)
    end)
end