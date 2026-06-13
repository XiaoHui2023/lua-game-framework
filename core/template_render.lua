---@class core.template_render
local g = {}
---@type utils.hook
local hook = require "utils.hook"
---@type core.exposed
local exposed_core = require "core.exposed"

---@alias core.placeholder_renderer_stage
---| "format" 格式化
---| "locale" 本地化
---| "coloring" 着色
---| "join" 连接（转placeholders为placeholder，只有优先级最高的有效）

---@class core.placeholder_renderer.options:hook.factory.options
---@field stage core.placeholder_renderer_stage 阶段
---@field on_render fun(context:core.exposed.entry) 渲染回调函数
---@field priority? number 优先级

-- 创建占位符渲染器
---@param args core.placeholder_renderer.options
---@return core.placeholder_renderer
g.create_placeholder_renderer = function (args)
    args.priority = args.priority or 0

    ---@class core.placeholder_renderer:hook.factory
    local o = hook.factory(args)
    o.set_class("core.placeholder_renderer")
    ---@type hook.set 阶段<core.placeholder_renderer_stage>
    o.stage = o.factory.set(args.stage)

    ---@type fun(context:core.exposed.entry) 渲染回调函数
    o.on_render = args.on_render

    ---@type hook.set 优先级<number>
    o.priority = o.factory.set(args.priority)

    -- 设置打印
    metatable.with_metatable(o, {
        __tostring = function(self)
            return string.format("<%s stage=%s>", self.class_name, self.stage())
        end
    })

    return o
end

---@class core.template_renderer.options:hook.factory.options
---@field exposed_contexts? core.exposed.context[] 暴露上下文列表

-- 创建模板渲染器
---@param args? core.template_renderer.options
---@return core.template_renderer
g.create_template_renderer = function (args)
    args = args or {}
    args.exposed_contexts = args.exposed_contexts or {}

    ---@class core.template_renderer:hook.factory
    ---@operator call(string):string
    local o = hook.factory(args)
    o.set_class("core.template_renderer")

    ---@type hook.add 暴露<core.exposed.context>
    o.exposed_contexts = o.factory.add({
        reversed = true,
    })

    ---@type hook.add 占位符渲染器列表
    o.placeholder_renderers = o.factory.add({
        compare = function(a, b)
            return a.priority() < b.priority()
        end
    })

    ---@type hook.computed format占位符渲染器列表
    local format_placeholder_renderers = o.factory.computed(function()
        return o.placeholder_renderers().filter(function(renderer)
            return renderer.stage() == "format"
        end)
    end)

    ---@type hook.computed locale占位符渲染器列表
    local locale_placeholder_renderers = o.factory.computed(function()
        return o.placeholder_renderers().filter(function(renderer)
            return renderer.stage() == "locale"
        end)
    end)

    ---@type hook.computed coloring占位符渲染器列表
    local coloring_placeholder_renderers = o.factory.computed(function()
        return o.placeholder_renderers().filter(function(renderer)
            return renderer.stage() == "coloring"
        end)
    end)

    ---@type hook.computed join占位符渲染器列表
    local join_placeholder_renderers = o.factory.computed(function()
        return o.placeholder_renderers().filter(function(renderer)
            return renderer.stage() == "join"
        end)
    end)

    -- 渲染单个占位符
    ---@param context core.exposed.entry
    local function render_token_placeholder(context)
        ---@type hook.computed[] 单个占位符阶段顺序
        local order = {
            format_placeholder_renderers,
            locale_placeholder_renderers,
            coloring_placeholder_renderers,
        }
        for _, computed in ipairs(order) do
            for _, renderer in ipairs(computed()) do
                renderer.on_render(context)
            end
        end
    end

    -- 渲染集合占位符
    ---@param entry core.exposed.entry
    local function render_join_placeholder(entry)
        ---@type list
        local join_renderers = join_placeholder_renderers()
        ---@type boolean 
        local has_matched = false
        -- 遍历
        join_renderers.for_each(
            ---@param renderer core.placeholder_renderer
            ---@param foreach_context list.for_each.context
            function (renderer, foreach_context)
                renderer.on_render(entry)
                has_matched = true
                foreach_context.stop()
            end
        )
        if not has_matched then
            entry.value = table.concat(entry.values, "")
        end
    end

    -- 搜索暴露
    ---@param placeholder string 占位符
    ---@return core.exposed.entry?
    local function search_exposed(placeholder)
        ---@type list
        local exposed_contexts = o.exposed_contexts.get()
        ---@type core.exposed.entry?
        local entry
        exposed_contexts.for_each(
            ---@param exposed_context core.exposed.context
            ---@param ctx list.for_each.context
            ---@return core.exposed.entry?
            function(exposed_context, ctx)
                entry = exposed_context.find(placeholder)
                if not entry then
                    return
                end
                ctx.stop()
            end
        )
        return entry
    end

    -- 渲染占位符
    ---@param placeholder string 占位符
    ---@return string
    local function render_placeholder(placeholder)
        ---@type core.exposed.entry?
        local entry = search_exposed(placeholder)
        if entry == nil then
            return string.format("{%s}",placeholder)
        end
        -- 考虑列表
        if entry.values ~= nil then
            -- 清除
            entry.value = nil
            -- 遍历
            for i, token in entry.values do
                ---@type core.exposed.entry
                local token_entry = table.clone(entry)
                token_entry.value = token
                token_entry.values = nil
                render_token_placeholder(token_entry)
                entry.values[i] = token_entry.value
            end
            -- 连接
            render_join_placeholder(entry)
        else
            render_token_placeholder(entry)
        end

        return entry.value
    end

    -- 运行
    ---@param template string 模板
    ---@return string 渲染后的文本
    o.run = function (template)
        return string.render_placeholders(template, render_placeholder)
    end

    -- 所有可暴露的属性
    ---@return string[]
    o.get_exposed_fields = function()
        ---@type string[]
        local fields = {}

        o.exposed_contexts().for_each(
            ---@param exposed_context core.exposed.context
            function(exposed_context)
                ---@type string[]
                local sub_fields = exposed_context.get_prop_fields()
                for _,sub_field in ipairs(sub_fields) do
                    fields[#fields+1] = exposed_context.name() .. ":" .. sub_field
                end
            end
        )
        return fields
    end

    -- 默认添加全局暴露
    o.exposed_contexts.add(exposed_core.GLOBAL)
    -- 添加暴露上下文
    for _, exposed_context in ipairs(args.exposed_contexts) do
        o.exposed_contexts.add(exposed_context)
    end

    metatable.callable(o,o.run)
    o.factory.register_hook_fields()

    return o
end

return g