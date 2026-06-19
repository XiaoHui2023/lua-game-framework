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
---@field stat_defs skill.stat.definition[] 字段说明
---@field on_run fun(skill.action):nil 运行事件
---@field target_key skill.target.key 目标

---@class skill.stat.definition 瀹氫箟
---@field name
---@field kind skill.stat.kind 绉嶇被
---@field unit skill.stat.unit 字段说明
---@field value number 字段说明
---@param args skill.action.options
---@return skill.action
M.create_action = function(args)
    args.stat_defs = args.stat_defs or {}

    ---@class skill.action: lib.reactive.factory
    local o = factory_model(args)
    o.set_class("skill.action")

    o.on_run = args.on_run

    ---@type reactive.computed
    o.context = o.factory.computed()

    ---@type reactive.add
    o.stats = o.factory.add()

    ---@type reactive.add 目标<skill.target>
    o.targets = o.factory.add()

    -- 运行
    o.run = function ()
        o.on_run(o)
    end

    ---@param args skill.stat.options
    ---@return skill.stat
    o.create_stat = function(args)
        ---@type skill.stat
        local stat = Stat(args)
        -- 娣诲姞
        o.stats.add(stat)
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

    o.factory.register_hook_fields()

    return o
end

return M
