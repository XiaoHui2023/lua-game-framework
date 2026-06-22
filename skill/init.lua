---@class framework.skill
local M = {}
package.loaded[...] = M

local factory_model = require "lib.reactive".factory
local Stat = require ".stat"

---@class skill.context
---@field unit? unit 技能绑定的单位
---@field owner? any 技能所属对象
---@field engine? table 底层技能运行时对象

---@class skill.effect
---@field name? string 效果名称
---@field description? string 效果描述
---@field on_attach? fun(skill:skill):nil 绑定到技能时触发
---@field on_detach? fun(skill:skill):nil 从技能解绑时触发

---@class skill.active_effect: skill.effect
---@field on_cast? fun(skill:skill.active, request:skill.cast_request):any 主动释放时触发

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
---@field name? string 技能显示名称
---@field description? string 技能描述
---@field context? skill.context 技能上下文
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

---@param args? skill.options 技能配置
---@return skill
M.new = function(args)
    args = args or {}
    args.context = args.context or {}

    ---@class skill: lib.reactive.factory
    local o = factory_model(args)
    o.set_class("skill")

    ---@type hook.set<string>
    o.factory.display_name.set(args.name or "")

    ---@type hook.set<string>
    o.factory.description.set(args.description or "")

    ---@type hook.set<skill.context>
    o.factory.context.set(args.context)

    ---@type hook.add<skill.stat>
    o.factory.stats.add()

    ---@type hook.add<skill.trigger>
    o.factory.triggers.add()

    ---@type hook.add<skill.target>
    o.factory.targets.add()

    ---@type hook.add<skill.effect>
    o.factory.passive_effects.add()

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

    return o
end

require ".passive"
require ".active"
require ".trigger"
require ".target"
require ".action"

return M
