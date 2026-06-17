---@type lib.reactive
local hook = require "lib.reactive"
local ValuePipeline = require "lib.value_pipeline"

---@alias skill.stat.unit
---| "angle"
---| "percent"
---| "integer"
---| "number"

---@class skill.stat.options: hook.factory.options
---@field kind string
---@field unit? skill.stat.unit
---@field value? number

---@param args skill.stat.options
---@return skill.stat
return function(args)
    args.value = args.value or 0
    args.unit = args.unit or "number"

    ---@class skill.stat: hook.factory
    local o = hook.factory(args)
    o.set_class("skill.stat")

    ---@type hook.set<string>
    o.kind = o.factory.set(args.kind)

    ---@type hook.set<skill.stat.unit>
    o.unit = o.factory.set(args.unit)

    ---@type lib.value_pipeline
    o.value_pipeline = ValuePipeline(args.value)

    ---@type hook.computed<number>
    o.value = o.factory.computed(function()
        return o.value_pipeline.run().value
    end)

    o.factory.register_hook_fields()

    return o
end
