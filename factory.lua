---@type utils.hook
local hook = require "utils.hook"
---@type models.timer
local Timer = require "models.timer"
---@type core.exposed
local exposed_core = require "core.exposed"
---@type core.template_render
local template_render_core = require "core.template_render"

---@class factory.options: hook.factory.options
---@field interval_time number? 定时器间隔
---@field description_template? string 描述模板

-- 创建工厂对象
---@param args? factory.options 参数
---@return factory
return function (args)
    args = args or {}
    args.interval_time = args.interval_time or 0.01
    args.description_template = args.description_template or ""

    ---@class factory: hook.factory
    local o = hook.factory(args)
    -- 设置类
    o.set_class("factory")

    ---@class hook.factory.factory
    o.factory = o.factory

    ---@class factory.timer
    ---@operator call(): hook.once_event
    o.factory.timer = {}

    ---@type hook.set 定时器间隔
    o.factory.timer.interval_time = o.factory.set(args.interval_time)

    -- 创建计时器
    ---@param func fun():nil 要执行的函数
    ---@return hook.once_event
    o.factory.timer.loop = function(func)
        ---@type hook.once_event
        local del = o.factory.once_event()

        del.add(Timer.loop(
            func,
            o.factory.timer.interval_time()
        ))
        o.delete.mount(del)

        return del
    end

    ---@type core.exposed.context 暴露
    o.factory.exposed_context = exposed_core.create_exposed_context({
        name = "factory",
    })

    -- 暴露属性
    ---@param obj hook.factory 对象
    ---@param expression fun():core.exposed.item? 表达式
    ---@return hook.once_event
    o.factory.expose_props = function (obj, expression)
        ---@type hook.once_event
        local delete = o.factory.exposed_context.set(obj.name(), expression)
        obj.delete.mount(delete)
        return delete
    end

    ---@type core.template_renderer 模板渲染器
    o.factory.template_renderer = template_render_core.create_template_renderer({
        exposed_contexts = {
            o.factory.exposed_context,
        },
    })

    ---@type hook.set 描述模板<string>
    o.factory.description_template = o.factory.set(args.description_template)

    ---@type hook.computed 描述<string>
    o.factory.description = o.factory.computed(function()
        local template = o.factory.description_template()
        if template ~= "" then
            return o.factory.template_renderer.run(template)
        end
        return ""
    end)

    metatable.callable(o.factory.timer, o.factory.timer.loop)

    return o
end