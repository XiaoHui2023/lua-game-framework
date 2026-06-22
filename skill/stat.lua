---@type lib.reactive
local reactive = require "lib.reactive"

---@alias skill.stat.unit
---| "angle"
---| "percent"
---| "integer"
---| "number"

---@class skill.stat.modifier
---@field callback fun(value:number, context?:table):number 属性修正回调

---@class skill.stat.value_pipeline
---@field modifiers reactive.add 属性修正器集合
---@field run fun(context?:table):skill.stat.value_result 执行属性计算
---@class skill.stat.value_result
---@field value number 属性计算结果
---@class skill.stat.options: lib.reactive.factory.options
---@field kind string 属性类型
---@field unit? skill.stat.unit 属性单位
---@field value? number 属性基础值
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
    o.factory.kind.set(args.kind)

    ---@type reactive.set<skill.stat.unit>
    o.factory.unit.set(args.unit)

    ---@type reactive.set<number>
    o.factory.base_value.set(args.value)

    ---@type skill.stat.value_pipeline
    o.value_pipeline = create_value_pipeline(o.base_value, o.factory)

    ---@type reactive.computed<number>
    o.factory.value.computed(function()
        return o.value_pipeline.run().value
    end)

    return o
end
