---@class core.exposed
---@operator call(core.exposed.context.options):core.exposed.context
local g = {}
---@type utils.hook
local hook = require "utils.hook"

---@alias core.exposed.unit
---| 'angle' 角度
---| 'percent' 百分比
---| 'integer' 整数
---| 'number' 数值

---@class core.exposed.entry
---@field unit core.exposed.unit 单位
---@field value any 值
---@field values any[] 值列表

---@class core.exposed.context.options: hook.factory.options

---@alias core.exposed.item core.exposed.entry|core.exposed.context

-- 向外暴露属性的上下文管理器
---@param args core.exposed.context.options? 选项
---@return core.exposed.context
g.create_exposed_context = function (args)
    ---@class core.exposed.context:hook.factory
    local o = hook.factory(args)
    o.set_class("core.exposed.context")

    ---@type hook.map 属性<hook.computed<core.exposed.entry>>
    o.props = o.factory.map()

    ---设置（属性或下级暴露）
    ---@param name string 名称
    ---@param expression fun():core.exposed.item? 表达式
    ---@return hook.once_event
    o.set = function(name, expression)
        ---@type hook.computed
        local computed = o.factory.computed(expression)
        ---@type hook.once_event
        local delete = o.props.set(name, computed)
        delete.add(computed.clear)
        return delete
    end

    ---获取
    ---@param name string 名称
    ---@return core.exposed.item?
    o.get = function(name)
        if not o.props.has(name) then
            return nil
        end
        ---@type hook.computed
        local computed = o.props.get(name)
        return computed.get()
    end

    -- 获取条目
    ---@param name string 名称
    ---@return core.exposed.entry?
    o.get_entry = function(name)
        ---@type core.exposed.item?
        local item = o.get(name)
        if not item then
            return nil
        end
        if o.is_instance_of(item, "core.exposed.context") then
            return nil
        end
        ---@cast item core.exposed.entry
        return item
    end

    -- 获取上下文
    ---@param name string 名称
    ---@return core.exposed.context?
    o.get_context = function(name)
        ---@type core.exposed.item?
        local item = o.get(name)
        if not item then
            return nil
        end
        if not o.is_instance_of(item, "core.exposed.context") then
            return nil
        end
        ---@cast item core.exposed.context
        return item
    end

    ---寻找条目（递归下级）
    ---@param path string 路径，用.分割
    ---@return core.exposed.entry?
    o.find = function(path)
        -- 非层级
        if not string.exists(path, ".") then
            return o.get_entry(path)
        end
        -- 层级
        local name = string.split(path, ".")[1]
        local child = o.get_context(name)
        if not child then
            return nil
        end
        -- 递归
        local postfix = string.sub(path, string.len(name) + 2)
        return child.find(postfix)
    end

    -- 所有可暴露的属性
    ---@return string[]
    o.get_prop_fields = function()
        ---@type string[]
        local fields = {}

        for name, computed in o.props.iter() do
            local item = computed.get()
            if o.is_instance_of(item, "core.exposed.context") then
                ---@type string[]
                local sub_fields = item.get_prop_fields()
                for _,sub_field in ipairs(sub_fields) do
                    fields[#fields+1] = name .. "." .. sub_field
                end
            else
                table.insert(fields, name)
            end
        end
        return fields
    end

    return o
end

-- 全局暴露属性
g.GLOBAL = g.create_exposed_context({
    name = "global",
})

metatable.callable(g, g.create_exposed_context)

return g