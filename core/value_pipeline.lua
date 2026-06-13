local pipeline = require "core.pipeline"
---@type utils.hook
local hook = require "utils.hook"

---@class core.value_pipeline.context
---@field value? number 数值
---@field exempt? boolean 标记是否免除

---@class core.value_pipeline.result
---@field value number 最终消耗量
---@field exempt boolean 是否被全部免除

---流水线计算数值
---（免除→覆盖→加减乘→上限→取整→最终）
---@param self core.value_pipeline 流水线
---@param context? core.value_pipeline.context 计算所需的上下文数据
---@return core.value_pipeline.result
local function compute_cost(self, context)
    context = context or {}
    context.value = context.value or 0
    context.exempt = context.exempt or false

    ---@type number 
    local value = context.value
    ---@type boolean
    local exempt = context.exempt
    ---@type boolean
    local can = true

    -- 直接免除
    if can then
        local rt = self.exempt.run(context)
        if rt ~= nil then
            exempt = rt
            can = false
        end
    end

    -- 直接设置固定值
    if can then
        local rt = self.fixed.run(context)
        if rt ~= nil then
            value = rt
            can = false
        end
    end

    -- 加减乘流程
    if can then
        value = self.flat.run(context, value)
        value = self.percentage.run(context, value)
    end

    -- 上限/下限控制
    if can then
        local rt = self.cap.run(context, value)
        if rt ~= nil then
            value = rt
            can = false
        end
    end

    -- 取整规则
    if can then
        local rt = self.round.run(context, value)
        if rt ~= nil then
            value = rt
            can = false
        end
    end

    -- 最终
    if can then
        local rt = self.final.run(context, value)
        if rt ~= nil then
            value = rt
            can = false
        end
    end

    return {
        value = (exempt and 0) or value,
        exempt = exempt,
    }
end

-- 数值流水线
---@param base? number 基础值
---@return core.value_pipeline
return function (base)
    base = base or 0

    ---@class core.value_pipeline: hook.factory
    ---@operator call(core.value_pipeline.context):core.value_pipeline.result
    local o = hook.factory()
    o.set_class("core.value_pipeline")

    ---@type core.pipeline 判断是否免除
    o.exempt = pipeline("or")
    ---@type core.pipeline 直接设定一个固定消耗
    o.fixed = pipeline("first")
    ---@type core.pipeline 加法调整
    o.flat = pipeline("chain")
    ---@type core.pipeline 乘法调整（倍率）
    o.percentage = pipeline("chain")
    ---@type core.pipeline 上限/下限控制
    o.cap = pipeline("first")
    ---@type core.pipeline 取整规则（向上/向下/保留）
    o.round = pipeline("first")
    ---@type core.pipeline 最终兜底（比如最小值、特殊规则）
    o.final = pipeline("first")

    -- 计算
    ---@param context? core.value_pipeline.context
    ---@return core.value_pipeline.result
    o.run = function(context)
        local result = compute_cost(o, context)

        -- 记录输出值
        o.last_value = result.value
        
        return result
    end

    ---@type number 最近一次运算的输出值
    o.last_value = base

    metatable.callable(o, o.run)
    o.factory.register_hook_fields()

    -- 初始化默认值
    if base ~= nil then
        o.flat.modifiers.add({
            callback = function (context, value)
                return value + base
            end,
            name = "base",
        })
    end

    return o
end