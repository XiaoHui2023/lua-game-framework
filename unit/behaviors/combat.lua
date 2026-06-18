---@type framework.unit
local M = require "..base"
---@type framework.event
local event = require "framework.event"

event.ON_UNIT_DAMAGE_TAKEN(function (api)
    local target = M.HANDLE_TO_OBJECT[api.target_handle]
    local source = M.HANDLE_TO_OBJECT[api.source_handle]
    if source and source.on_attack_release then
        source.on_attack_release(target)
    end
end)

---@class unit.options
---@field health number? 字段说明

---@class unit.combat.context: lib.combat.context
---@field target unit 目标
---@field source? unit 字段说明
---@field inflictor? object 字段说明

---@class unit.combat.result: lib.combat.result
---@field target unit 目标
---@field source unit 来源
---@field inflictor object 施加者（中介或来源本身）
---@field is_lethal boolean 是否致命

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o
    args.health = args.health or M.DEFAULT_HEALTH
    args.max_health = args.max_health or M.DEFAULT_MAX_HEALTH
    args.damage = args.damage or M.DEFAULT_DAMAGE

    ---@type hook.set<number>
    o.health = o.factory.set(args.health)
    ---@type hook.set<number>
    o.max_health = o.factory.set(args.max_health)
    ---@type hook.set<number> 伤害
    o.damage = o.factory.set(args.damage)
    ---@type hook.event
    o.on_attack_release = o.factory.event()
    ---@type hook.event
    o.on_damage_taken = o.factory.event()
    ---@type hook.event
    o.on_damage_dealt = o.factory.event()
    ---@type hook.event
    o.on_crowd_controlled = o.factory.event()
    ---@type hook.event 生命值变化事件（新生命值，旧生命值）
    o.on_health_changed = o.factory.event()

    ---@type lib.combat
    local combat = require "lib.combat"()

    ---@type lib.combat.attacker
    o.combat_attacker = combat.attacker
    ---@type lib.combat.defender
    o.combat_defender = combat.defender

    -- 打击
    ---@param context unit.combat.context 参数说明
    o.combat = function(context)
        ---@type unit
        local target = context.target

        context.source = context.source or o
        context.inflictor = context.inflictor or context.source

        ---@class unit.combat.result
        local result = combat.run({
            attacker = o.combat_attacker,
            defender = target.combat_defender,
            context = context
        })

        result.is_lethal = result.damage >= target.health
        result.target = context.target
        result.source = context.source
        result.inflictor = context.inflictor

        o.deal_damage(result)
        target.apply_cc(result)

        return result
    end

    -- 造成伤害
    ---@param result unit.combat.result 结果
    o.deal_damage = function(result)
        ---@type unit
        local target = result.target
        ---@type number
        local damage = result.damage

        if result.has_damage then
            target.set_health(target.health - damage)

            -- 触发造成伤害事件
            o.on_damage_dealt(result)
            -- 触发受到伤害事件
            target.on_damage_taken(result)
        end
    end

    -- 应用控制效果
    ---@param result unit.combat.result 结果
    o.apply_cc = function(result)
        if result.has_cc then
            o.on_crowd_controlled(result)
        end
    end

    o.set_health = function(health)
        local old_health = o.health()
        o.health.set(health)
    end

end
