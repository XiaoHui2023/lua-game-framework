---@type models.unit
local g = require "..base"
---@type models.event
local event = require "models.event"

event.ON_UNIT_DAMAGE_TAKEN.add(function (target_handle, source_handle)
    local target = g.HANDLE_TO_OBJECT[target_handle]
    local source = g.HANDLE_TO_OBJECT[source_handle]
    source.on_attack_release(target)
end)

---@class unit.options
---@field health number? 血量
---@field max_health number? 最大血量
---@field damage number? 伤害

---@class unit.combat.context: core.combat.context
---@field target unit 目标
---@field source? unit 来源
---@field inflictor? object 施加者（中介或来源本身）

---@class unit.combat.result: core.combat.result
---@field target unit 目标
---@field source unit 来源
---@field inflictor object 施加者（中介或来源本身）
---@field is_lethal boolean 是否致命

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o
    args.health = args.health or g.DEFAULT_HEALTH
    args.max_health = args.max_health or g.DEFAULT_MAX_HEALTH
    args.damage = args.damage or g.DEFAULT_DAMAGE

    ---@type hook.set 血量<number>
    o.health = o.factory.set(args.health)
    ---@type hook.set 最大血量<number>
    o.max_health = o.factory.set(args.max_health)
    ---@type hook.set 伤害<number>
    o.damage = o.factory.set(args.damage)
    ---@type hook.event 普通攻击释放事件（目标）
    o.on_attack_release = o.factory.event()
    ---@type hook.event 受到伤害事件（unit.combat.result）
    o.on_damage_taken = o.factory.event()
    ---@type hook.event 造成伤害事件（unit.combat.result）
    o.on_damage_dealt = o.factory.event()
    ---@type hook.event 被控制事件（unit.combat.result）
    o.on_crowd_controlled = o.factory.event()
    ---@type hook.event 生命值变化事件（新生命值，旧生命值）
    o.on_health_changed = o.factory.event()

    ---@type core.combat
    local combat = require "core.combat"()

    ---@type core.combat.attacker
    o.combat_attacker = combat.attacker
    ---@type core.combat.defender
    o.combat_defender = combat.defender

    -- 打击
    ---@param context unit.combat.context 上下文
    ---@return unit.combat.result 结果
    o.combat = function(context)
        ---@type unit
        local target = context.target

        -- 默认值
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

    -- 设置生命值
    ---@param health number 生命值
    o.set_health = function(health)
        local old_health = o.health
        o.health.set(health)
        -- 触发生命值变化事件
        o.on_health_changed(health, old_health)
    end

    -- 暴露
    o.factory.exposed_context.set("health", function ()
        return {
            value = o.health(),
            unit = "number",
        }
    end)
    o.factory.exposed_context.set("max_health", function ()
        return {
            value = o.max_health(),
            unit = "number",
        }
    end)
    o.factory.exposed_context.set("damage", function ()
        return {
            value = o.damage(),
            unit = "number",
        }
    end)
end