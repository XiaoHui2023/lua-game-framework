---@type lib.tablex
local table = require "lib.tablex"
---@class framework.skill
local M = require "framework.skill"
local factory_model = require "lib.reactive".factory
local Stat = require ".stat"
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.skill.apis
local apis = require ".apis"

---@class skill.action.options: lib.reactive.factory.options
---@field stat_defs? table<string, skill.stat.definition> 动作使用的属性定义表
---@field on_run fun(skill.action):nil 运行事件
---@field target_key skill.target.key 目标

---@class skill.stat.definition
---@field name? string 属性名称，省略时使用定义表键名
---@field kind skill.stat.kind 属性类型
---@field unit skill.stat.unit 属性单位
---@field value number 属性初始值
---@param args skill.action.options
---@return skill.action
M.create_action = function(args)
    args.stat_defs = args.stat_defs or {}

    ---@class skill.action: lib.reactive.factory
    local o = factory_model(args)
    o.factory.set_class("skill.action")

    o.on_run = args.on_run

    ---@type reactive.computed
    o.factory.context.computed()

    ---@type reactive.add
    o.factory.stats.add()

    ---@type reactive.add 目标<skill.target>
    o.factory.targets.add()

    -- 运行
    o.run = function ()
        o.on_run(o)
    end

    ---@param args skill.stat.options
    ---@return skill.stat
    o.create_stat = function(args)
        ---@type skill.stat
        local stat = Stat(args)
        -- 绑定动作属性
        return stat
    end

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

    apis.ON_CREATE_ACTION({
        action = o,
        options = args,
    })

    return o
end

return M
