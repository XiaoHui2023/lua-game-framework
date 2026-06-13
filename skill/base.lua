---@class models.skill
local g = {}
local factory_model = require "models.factory"
local Stat = require "core.stat"

---@class skill.context
---@field unit unit 单位

---@alias skill.stat.kind
---| 'damage' 伤害
---| 'damage_coef' 伤害系数
---| 'range' 范围
---| 'radius' 半径
---| 'distance' 距离
---| 'cone_angle' 扇形角度
---| 'cooldown' 冷却时间
---| 'duration' 持续时间

---@class skill.options: factory.options
---@field context? skill.context 上下文

-- 创建技能
---@param args skill.options
---@return skill
g.new = function(args)
    args.context = args.context or {}

    ---@class skill: factory
    local o = factory_model(args)
    o.set_class("skill")

    ---@type hook.set 上下文<skill.context>
    o.context = o.factory.set(args.context)

    ---@type hook.add 数据<skill.stat>
    o.stats = o.factory.add()

    ---@type hook.add 触发器<skill.trigger>
    o.triggers = o.factory.add()

    ---@type hook.add 目标<skill.target>
    o.targets = o.factory.add()

    -- 创建数据
    ---@param args core.stat.options
    ---@return core.stat
    o.create_stat = function(args)
        ---@type core.stat
        local stat = Stat(args)
        -- 暴露属性
        o.factory.expose_props(stat, function ()
            return {
                value = stat.value(),
                unit = stat.unit(),
            }
        end)
        -- 添加
        o.stats.add(stat)
        o.children.add(stat)
        return stat
    end

    -- 添加触发器时提供上下文
    o.triggers.wrap_add(
        ---@param trigger skill.trigger
        ---@return skill.trigger
        function(trigger)
            trigger.context.set(o.context())
            o.children.add(trigger)
            return trigger
        end
    )

    -- 添加目标时提供上下文
    o.targets.wrap_add(
        ---@param target skill.target
        ---@return skill.target
        function(target)
            target.context.set(o.context())
            o.children.add(target)
            return target
        end
    )

    o.factory.register_hook_fields()

    return o
end

return g