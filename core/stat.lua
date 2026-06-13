---@type utils.hook
local hook = require "utils.hook"
local ValuePipeline = require "core.value_pipeline"

---@class core.stat.options: hook.factory.options
---@field kind string 种类
---@field unit? core.exposed.unit 单位
---@field value? number 基础值

-- 技能数据
---@param args core.stat.options
---@return core.stat
return function (args)
    args.value = args.value or 0
    args.unit = args.unit or "number"

    ---@class core.stat: hook.factory
    local o = hook.factory(args)
    o.set_class("core.stat")

    ---@type hook.set 种类<string>
    o.kind = o.factory.set(args.kind)

    ---@type hook.set 单位<core.exposed.unit>
    o.unit = o.factory.set(args.unit)

    ---@type core.value_pipeline 数据管道
    o.value_pipeline = ValuePipeline(args.value)

    ---@type hook.computed 数据<number>
    o.value = o.factory.computed(function()
        return o.value_pipeline.run().value
    end)

    o.factory.register_hook_fields()

    return o
    
end