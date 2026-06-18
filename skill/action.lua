---@type lib.tablex
local table = require "lib.tablex"
---@class framework.skill
local g = require ".base"
local factory_model = require "lib.reactive".factory
local Stat = require ".stat"
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.skill.apis
local apis = require ".apis"

---@class skill.action.options: factory.options
---@field stat_defs skill.stat.definition[] 鏁版嵁瀹氫箟鍒楄〃
---@field on_run fun(skill.action):nil 运行事件
---@field target_key skill.target.key 目标

---@class skill.stat.definition 瀹氫箟
---@field name
---@field kind skill.stat.kind 绉嶇被
---@field unit skill.stat.unit 鍗曚綅
---@field value number 锟
---@type reactive.event 鍒涘缓鍔ㄤ綔浜嬩欢<skill.action,skill.action.options>
g.ON_CREATE_ACTION = apis.ON_CREATE_ACTION

-- 鍒涘缓鍔ㄤ綔
---@param args skill.action.options
---@return skill.action
g.create_action = function(args)
    args.stat_defs = args.stat_defs or {}

    ---@class skill.action: factory
    local o = factory_model(args)
    o.set_class("skill.action")

    o.on_run = args.on_run

    ---@type reactive.computed 涓婁笅鏂噑kill.context>
    o.context = o.factory.computed()

    ---@type reactive.add 鏁版嵁<skill.stat>
    o.stats = o.factory.add()

    ---@type reactive.add 目标<skill.target>
    o.targets = o.factory.add()

    -- 运行
    o.run = function ()
        o.on_run(o)
    end

    -- 鍒涘缓鏁版嵁
    ---@param args skill.stat.options
    ---@return skill.stat
    o.create_stat = function(args)
        ---@type skill.stat
        local stat = Stat(args)
        -- 鏆撮湶灞烇拷
        -- 娣诲姞
        o.stats.add(stat)
        return stat
    end

    -- 闈欐€佹敞鍐屾暟锟
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

    -- 瑙﹀彂鍒涘缓鍔ㄤ綔浜嬩欢
    g.ON_CREATE_ACTION({
        action = o,
        options = args,
    })

    o.factory.register_hook_fields()

    return o
end

return g
