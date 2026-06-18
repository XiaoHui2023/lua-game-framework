---@class framework.skill
local M = {}

local factory_model = require "lib.reactive".factory
local Stat = require ".stat"

---@class skill.context
---@field unit? unit 字段说明
---@field owner? any 字段说明
---@field engine? table 字段说明

---@class skill.effect
---@field name? string 字段说明
---@field description? string 字段说明
---@field on_attach? fun(skill:skill):nil 字段说明
---@field on_detach? fun(skill:skill):nil 字段说明

---@class skill.active_effect: skill.effect
---@field on_cast? fun(skill:skill.active, 字段说明

---@alias skill.stat.kind
---| 'damage' 伤害
---| 'damage_coef' 伤害系数
---| 'range' 范围
---| 'radius' 半径
---| 'distance' 距离
---| 'cone_angle' 扇形角度
---| 'cooldown'
---| 'duration'

---@class skill.options: factory.options
---@field name? string 字段说明
---@field description? string 字段说明
---@field context? skill.context 字段说明
---@field passive_effects? skill.effect[] 字段说明

---@param effect skill.effect
---@param skill skill
local function attach_effect(effect, skill)
    if type(effect.on_attach) == "function" then
        effect.on_attach(skill)
    end
end

---@param effect skill.effect
---@param skill skill
local function detach_effect(effect, skill)
    if type(effect.on_detach) == "function" then
        effect.on_detach(skill)
    end
end

---@param args? skill.options 参数说明
---@return skill
M.new = function(args)
    args = args or {}
    args.context = args.context or {}

    ---@class skill: factory
    local o = factory_model(args)
    o.set_class("skill")

    ---@type hook.set<string>
    o.display_name = o.factory.set(args.name or "")

    ---@type hook.set<string>
    o.description = o.factory.set(args.description or "")

    ---@type hook.set<skill.context>
    o.context = o.factory.set(args.context)

    ---@type hook.add<skill.stat>
    o.stats = o.factory.add()

    ---@type hook.add<skill.trigger>
    o.triggers = o.factory.add()

    ---@type hook.add<skill.target>
    o.targets = o.factory.add()

    ---@type hook.add<skill.effect>
    o.passive_effects = o.factory.add()

    o.passive_effects.wrap_add(function(effect)
        attach_effect(effect, o)
        o.delete.add(function()
            detach_effect(effect, o)
        end)
        return effect
    end)

    ---@param stat_args skill.stat.options
    ---@return skill.stat
    o.create_stat = function(stat_args)
        ---@type skill.stat
        local stat = Stat(stat_args)
        o.stats.add(stat)
        o.factory.capture("", stat)
        return stat
    end

    ---@param effect skill.effect
    ---@return fun()
    o.add_passive_effect = function(effect)
        return o.passive_effects.add(effect)
    end

    o.triggers.wrap_add(
        ---@param trigger skill.trigger
        ---@return skill.trigger
        function(trigger)
            trigger.context.set(o.context())
            o.factory.capture("", trigger)
            return trigger
        end
    )

    o.targets.wrap_add(
        ---@param target skill.target
        ---@return skill.target
        function(target)
            target.context.set(o.context())
            o.factory.capture("", target)
            return target
        end
    )

    if args.passive_effects ~= nil then
        for _, effect in ipairs(args.passive_effects) do
            o.passive_effects.add(effect)
        end
    end

    o.destroy = function()
        o.factory.dispose()
    end

    o.dispose = o.destroy

    o.factory.register_hook_fields()

    return o
end

return M
