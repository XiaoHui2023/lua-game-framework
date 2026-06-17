---@class framework.skill
local g = require ".base"

---@class skill.active.options: skill.options
---@field cooldown? number 初始冷却时间
---@field max_cooldown number 初始最大冷却时�?

-- 技�?
---@param args skill.active.options
---@return skill.active
g.create_active = function (args)
    args.cooldown = args.cooldown or 0

    ---@class skill.active: skill
    local o = g.new(args)
    o.set_class("skill.active")

    ---@type hook.set 剩余冷却时间<number>
    o.cooldown = o.factory.set(args.cooldown)

    ---@type skill.stat 最大冷却时�?
    o.max_cooldown = o.create_stat({
        kind = "cooldown",
        unit = "number",
        value = args.max_cooldown,
    })

    ---@type hook.semaphore �?
    o.lock = o.factory.semaphore()

    ---@type hook.event 释放技能事�?
    o.on_cast = o.factory.event()
    
    ---@type hook.event 冷却就绪事件
    o.on_cooldown_ready = o.factory.event()
    
    ---@type hook.event 进入冷却事件
    o.on_cooldown_start = o.factory.event()

    -- 减少冷却时间
    ---@param delta number 减少的冷却时�?
    ---@return boolean 是否减少了冷却时�?
    o.reduce_cooldown = function (delta)
        if delta <= 0 then
            return false
        end

        o.cooldown.set(o.cooldown() - delta)

        return true
    end

    -- 释放
    ---@return boolean 是否释放成功
    o.cast = function()
        -- 被锁�?
        if o.lock.is_acquired() then
            return false
        end

        -- 还在冷却
        if o.cooldown() > 0 then
            return false
        end

        -- 触发释放事件
        o.on_cast()

        return true
    end

    -- 重载冷却时间设置
    o.cooldown.wrap_set(function (value)
        local max_cooldown = o.max_cooldown()
        value = (value < 0 and 0) or value
        value = (value > max_cooldown and max_cooldown) or value
        return value
    end)
    o.cooldown.on_change.add(function (value,old_value)
        if old_value == 0 and value > 0 then
            o.on_cooldown_start()
        elseif old_value > 0 and value == 0 then
            o.on_cooldown_ready()
        end
    end)

    return o
end
