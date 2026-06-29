---@type framework.unit
local M = require "framework.unit"
---@type framework.event.apis
local event_apis = require "framework.event.apis"

event_apis.ON_UNIT_DAMAGE_TAKEN(function (api)
    local target = M.HANDLE_TO_OBJECT[api.target_handle]
    local source = M.HANDLE_TO_OBJECT[api.source_handle]
    if source and source.on_attack_release then
        source.on_attack_release(target)
    end
end)
---@class unit.options
---@field health number? 初始生命�?
---@class unit.combat.context: framework.damage.context
---@field target unit 目标
---@field source? unit 伤害来源单位，省略时使用攻击�?
---@field inflictor? object 实际施加伤害的对象，省略时使用来源单�?
---@class unit.combat.result: framework.damage.result
---@field target unit 目标
---@field source unit 来源
---@field inflictor object 施加者（中介或来源本身）
---@field is_lethal boolean 是否致命
---@param o unit
---@param args unit.options
return function (o,args)
---@class unit
    o = o
    args.health = args.health or M.settings.DEFAULT_HEALTH
    args.max_health = args.max_health or M.settings.DEFAULT_MAX_HEALTH
    args.damage = args.damage or M.settings.DEFAULT_DAMAGE
---@type hook.set<number>
    o.factory.ref_field("health", args.health)
---@type hook.set<number>
    o.factory.ref_field("max_health", args.max_health)
---@type hook.set<number> 伤害
    o.factory.ref_field("damage", args.damage)
---@type hook.event
    o.factory.event_field("on_attack_release")
---@type hook.event
    o.factory.event_field("on_damage_taken")
---@type hook.event
    o.factory.event_field("on_damage_dealt")
---@type hook.event
    o.factory.event_field("on_crowd_controlled")
---@type hook.event 生命值变化事件（新生命值，旧生命值）
    o.factory.event_field("on_health_changed")
---@type framework.damage
    local combat = require "framework.damage"()
---@type framework.damage.source_side
    o.combat_attacker = combat.attacker
---@type framework.damage.target_side
    o.combat_defender = combat.defender

    -- 打击
---@param context unit.combat.context 本次战斗计算上下�?
    o.combat = function(context)
---@type unit
        local target = context.target

        context.source = context.source or o
        context.inflictor = context.inflictor or context.source
        context.damage = context.damage or o.damage()
        context.target = target
---@class unit.combat.result
        local result = combat.run(context)

        result.is_lethal = result.damage >= target.health()
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
            target.set_health(target.health() - damage)

            -- 触发造成伤害事件
            o.on_damage_dealt(result)
            -- 触发受到伤害事件
            target.on_damage_taken(result)
        end
    end

    -- 应用控制效果
---@param result unit.combat.result 结果
    o.apply_cc = function(result)
        if result.has_cc or result.has_control then
            o.on_crowd_controlled(result)
        end
    end
    o.set_health = function(health)
        local old_health = o.health()
        o.health.set(health)
        o.on_health_changed(o.health(), old_health)
    end

end
