---@class framework.skill
local M = {}
package.loaded[...] = M

local factory_model = require "lib.reactive".factory
local Stat = require ".stat"

---@class skill.context
---@field unit? unit 技能绑定的单位
---@field owner? any 技能所属对�?
---@class skill.effect
---@field name? string 效果名称
---@field description? string 效果描述
---@field on_attach? fun(skill:skill):nil 绑定到技能时触发
---@field on_detach? fun(skill:skill):nil 从技能解绑时触发

---@class skill.active_effect: skill.effect
---@class skill.active_effect: skill.effect
---@alias skill.stat.kind
---| 'damage' 伤害
---| 'damage_coef' 伤害系数
---| 'range' 范围
---| 'radius' 半径
---| 'distance' 距离
---| 'cone_angle' 扇形角度
---| 'cooldown'
---| 'duration'

---@class skill.options: lib.reactive.factory.options

---@field passive_effects? skill.effect[] 初始被动效果列表

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
M.new = function(args)
    args = args or {}
    args.context = args.context or {}

    ---@class skill: lib.reactive.factory
    local o = factory_model(args)
    o.factory.set_class("skill")

    ---@type hook.set<string>
    o.factory.ref_field("display_name", args.name or "")

    ---@type hook.set<string>
    o.factory.ref_field("description", args.description or "")

    ---@type hook.set<skill.context>
    o.factory.ref_field("context", args.context)

    ---@type hook.add<skill.stat>
    o.factory.collection_field("stats")

    ---@type hook.add<skill.trigger>
    o.factory.collection_field("triggers")

    ---@type hook.add<skill.target>
    o.factory.collection_field("targets")

    ---@type hook.add<skill.effect>
    o.factory.collection_field("passive_effects")

    o.passive_effects.wrap_add(function(effect)
        attach_effect(effect, o)
        o.factory.delete.add(function()
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

    return o
end

require ".passive"
require ".active"
require ".trigger"
require ".target"
require ".search"
require ".action"

return M
