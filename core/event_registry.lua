---@type utils.hook
local hook = require "utils.hook"

---@param keys string[] 事件字段列表
---@return core.event_registry
return function (keys)
    ---@class core.event_registry
    local o = {}

    ---@type table<string, hook.event> 事件表
    local map = {}
    for _, reg_key in ipairs(keys) do
        map[reg_key] = hook.event()
    end
    
    o.get = function(key)
        return map[key]
    end

    o.add = function (key,callback)
        return map[key].add(callback)
    end

    -- 注册
    ---@param obj hook.factory
    ---@param map table<string,hook.event> 字段事件映射表（注册表 -> 对象事件）
    o.register = function(obj,map)
        for key, trigger in table.sorted_pairs(map) do
            ---@type hook.event
            local handler = o.get(key)
            obj.delete.add(trigger.add(function (...)
                handler.run(obj,...)
            end))
        end
    end

    return o
end