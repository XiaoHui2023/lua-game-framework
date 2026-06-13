---@class models.skill
local g = require ".base"
local factory_model = require "models.factory"
local Stat = require "core.stat"
---@type utils.hook
local hook = require "utils.hook"

---@class skill.action.options: factory.options
---@field stat_defs skill.stat.definition[] 数据定义列表
---@field on_run fun(skill.action):nil 运行事件
---@field target_key skill.target.key 目标

---@class skill.stat.definition 定义
---@field name? string 名称
---@field kind skill.stat.kind 种类
---@field unit core.exposed.unit 单位
---@field value number 值

---@type hook.event 创建动作事件<skill.action,skill.action.options>
g.ON_CREATE_ACTION = hook.event()

-- 创建动作
---@param args skill.action.options
---@return skill.action
g.create_action = function(args)
    args.stat_defs = args.stat_defs or {}

    ---@class skill.action: factory
    local o = factory_model(args)
    o.set_class("skill.action")

    o.on_run = args.on_run

    ---@type hook.computed 上下文<skill.context>
    o.context = o.factory.computed()

    ---@type hook.add 数据<skill.stat>
    o.stats = o.factory.add()

    ---@type hook.add 目标<skill.target>
    o.targets = o.factory.add()

    -- 运行
    o.run = function ()
        o.on_run(o)
    end

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
        return stat
    end

    -- 静态注册数据
    for name, stat_def in table.sorted_pairs(args.stat_defs) do
        stat_def.name = stat_def.name or name
        local stat = o.create_stat({
            name = stat_def.name,
            kind = stat_def.kind,
            unit = stat_def.unit,
            value = stat_def.value,
            
        })
        o[stat_def.name] = stat
    end

    -- 触发创建动作事件
    g.ON_CREATE_ACTION(o, args)

    o.factory.register_hook_fields()

    return o
end

return g