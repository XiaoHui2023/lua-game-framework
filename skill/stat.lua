---@type lib.reactive
local reactive = require "lib.reactive"

---@alias skill.stat.unit
---| "angle"
---| "percent"
---| "integer"
---| "number"

---@class skill.stat.modifier
---@field callback fun(value:number, context

---@class skill.stat.value_pipeline
---@field modifiers reactive.add 字段说明
---@field run fun(context
---@class skill.stat.value_result
---@field value number 字段说明
---@class skill.stat.options: reactive.factory.options
---@field kind string 字段说明
---@param get_base_value fun():number
---@param owner_factory reactive.factory
---@return skill.stat.value_pipeline
local function create_value_pipeline(get_base_value, owner_factory)
    ---@type skill.stat.value_pipeline
    local pipeline = {
        modifiers = owner_factory.add(),
    }

    pipeline.run = function(context)
        local value = get_base_value()
        pipeline.modifiers().for_each(function(modifier)
            if modifier.enabled ~= false then
                value = modifier.callback(value, context)
            end
        end)
        return {
            value = value,
        }
    end

    return pipeline
end

---@param args skill.stat.options
---@return skill.stat
return function(args)
    args = args or {}
    args.value = args.value or 0
    args.unit = args.unit or "number"

    ---@class skill.stat: reactive.factory
    local o = reactive.factory(args)
    o.set_class("skill.stat")

    ---@type reactive.set<string>
    o.kind = o.factory.set(args.kind)

    ---@type reactive.set<skill.stat.unit>
    o.unit = o.factory.set(args.unit)

    ---@type reactive.set<number>
    o.base_value = o.factory.set(args.value)

    ---@type skill.stat.value_pipeline
    o.value_pipeline = create_value_pipeline(o.base_value, o.factory)

    ---@type reactive.computed<number>
    o.value = o.factory.computed(function()
        return o.value_pipeline.run().value
    end)

    o.factory.register_hook_fields()

    return o
end
