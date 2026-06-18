---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.appearance
local M = require "framework.appearance.base"
---@type lib.reactive
local reactive = require "lib.reactive"

---@param modifier framework.appearance.modifier
---@return boolean
local function is_modifier(modifier)
    return type(modifier) == "table" and type(modifier.run) == "function" and type(modifier.kind) == "string"
end

---@param a framework.appearance.modifier
---@param b framework.appearance.modifier
---@return boolean
local function compare_modifier(a, b)
    if a.exclusive ~= b.exclusive then
        return a.exclusive == true
    end
    if a.priority ~= b.priority then
        return a.priority < b.priority
    end
    return false
end

---@class framework.appearance.renderer.options: lib.reactive.factory.options
---@field dt? number 字段说明
---@field apply_change? fun(args:framework.appearance.apply_change.args) 字段说明
---@field reset_kind? fun(args:framework.appearance.reset_kind.args) 字段说明

---@class framework.appearance.apply_change.args
---@field kind string
---@field value any
---@field result framework.appearance.result

---@class framework.appearance.reset_kind.args
---@field reason string
---@field kind string
---@field modifier? framework.appearance.modifier 字段说明
---@field replacement? framework.appearance.modifier 字段说明
---@field result? framework.appearance.result 字段说明

---@param args? framework.appearance.renderer.options 参数说明
---@return framework.appearance.renderer
function M.renderer(args)
    args = args or {}
    local dt = args.dt or 0
    local apply_change = args.apply_change
    local reset_kind = args.reset_kind
    assert(type(dt) == "number", "appearance renderer dt must be a number")
    assert(apply_change == nil or type(apply_change) == "function", "appearance renderer apply_change must be a function")
    assert(reset_kind == nil or type(reset_kind) == "function", "appearance renderer reset_kind must be a function")

    ---@class framework.appearance.renderer : lib.reactive.factory
    local o = reactive.factory(args)
    o.set_class("framework.appearance.renderer")

    o.modifiers = o.factory.add({
        name = "modifiers",
        compare = compare_modifier,
        prevent_duplicate = true,
        item_checker = is_modifier,
    })

    o.dt = dt
    o.on_update = o.factory.event({ name = "update" })
    o.before_render = o.factory.event({ name = "before_render" })
    o.after_resolve = o.factory.event({ name = "after_resolve" })
    o.on_complete = o.factory.event({ name = "complete" })
    o.on_interrupt = o.factory.event({ name = "interrupt" })
    o.on_reset_kind = o.factory.event({ name = "reset_kind" })
    o.on_apply_change = o.factory.event({ name = "apply_change" })
    o.loop_scope = o.factory.delete({ name = "loop" })

    ---@param kind string
    ---@param reason string
    ---@param modifier? framework.appearance.modifier 参数说明
    ---@param replacement? framework.appearance.modifier 参数说明
    ---@param result? framework.appearance.result 参数说明
    function o.reset_kind(kind, reason, modifier, replacement, result)
        local reset_args = {
            reason = reason,
            kind = kind,
            modifier = modifier,
            replacement = replacement,
            result = result,
        }
        o.on_reset_kind(reset_args)
        if reset_kind ~= nil then
            reset_kind(reset_args)
        end
    end

    ---@param modifier framework.appearance.modifier
    ---@param reason string
    ---@param replacement? framework.appearance.modifier 参数说明
    function o.interrupt_modifier(modifier, reason, replacement)
        if modifier.interrupted or modifier.finished then
            return
        end
        modifier.interrupt(reason)
        o.on_interrupt(modifier, reason, replacement)
        if modifier.reset_on_interrupt then
            o.reset_kind(modifier.kind, reason, modifier, replacement)
        end
    end

    ---@param kind string
    ---@param interrupt_args? { 参数说明
    function o.interrupt_kind(kind, interrupt_args)
        interrupt_args = interrupt_args or {}
        local reason = interrupt_args.reason or "interrupt_kind"
        local should_reset = interrupt_args.reset or false
        local replacement = interrupt_args.replacement
        local did_interrupt = false

        o.modifiers().for_each(function(modifier)
            if modifier.kind == kind and not modifier.interrupted and not modifier.finished then
                did_interrupt = true
                modifier.interrupt(reason)
                o.on_interrupt(modifier, reason, replacement)
                should_reset = should_reset or modifier.reset_on_interrupt
            end
        end)

        if did_interrupt and should_reset then
            o.reset_kind(kind, reason, nil, replacement)
        end
    end

    ---@param interrupt_args? { 参数说明
    function o.interrupt_all(interrupt_args)
        interrupt_args = interrupt_args or {}
        local reason = interrupt_args.reason or "interrupt_all"
        local reset_all = interrupt_args.reset or false
        local reset_by_kind = {}

        o.modifiers().for_each(function(modifier)
            if not modifier.interrupted and not modifier.finished then
                modifier.interrupt(reason)
                o.on_interrupt(modifier, reason)
                if reset_all or modifier.reset_on_interrupt then
                    reset_by_kind[modifier.kind] = true
                end
            end
        end)

        for kind in pairs(reset_by_kind) do
            o.reset_kind(kind, reason)
        end
    end

    ---@param modifier framework.appearance.modifier
    ---@return fun()
    function o.add(modifier)
        if modifier.replace_previous then
            o.interrupt_kind(modifier.kind, {
                reason = "replace_previous",
                reset = modifier.reset_before_start,
                replacement = modifier,
            })
        end
        local remove = o.modifiers.add(modifier)
        o.delete.mount(remove)
        if modifier.delete ~= nil and modifier.delete.mount ~= nil then
            modifier.delete.mount(remove)
        end
        return remove
    end

    ---@param args? framework.appearance.modifier.options 参数说明
    ---@return framework.appearance.modifier
    function o.create_modifier(args)
        local modifier = M.modifier(args)
        o.add(modifier)
        return modifier
    end

    function o.clear()
        o.modifiers.clear()
    end

    ---@param args? table 参数说明
    ---@return framework.appearance.data
    function o.create_data(args)
        if args == nil then
            return M.data({ dt = o.dt })
        end
        if args.dt ~= nil then
            return M.data(args)
        end
        local data_args = {}
        for key, value in pairs(args) do
            data_args[key] = value
        end
        data_args.dt = o.dt
        return M.data(data_args)
    end

    ---@param result framework.appearance.result
    function o.apply_result(result)
        for kind, value in pairs(result.changes) do
            local apply_args = {
                kind = kind,
                value = value,
                result = result,
            }
            o.on_apply_change(apply_args)
            if apply_change ~= nil then
                apply_change(apply_args)
            end
        end
    end

    ---@param args? table|framework.appearance.data 参数说明
    ---@return framework.appearance.result
    function o.render(args)
        local data = o.create_data(args)
        local reset_on_finish = {}
        o.before_render(data)

        o.modifiers().for_each(function(modifier, context)
            local did_run = modifier.run(data)
            if did_run and modifier.exclusive then
                context.stop()
            end
        end)

        local result = M.resolve(data)
        o.after_resolve(result)
        o.apply_result(result)

        o.modifiers().for_each(function(modifier)
            local was_finished = modifier.finished
            local was_interrupted = modifier.interrupted
            modifier.complete(result)
            if not was_finished and not was_interrupted and modifier.finished and modifier.reset_on_finish then
                reset_on_finish[modifier.kind] = true
            end
        end)

        for kind in pairs(reset_on_finish) do
            o.reset_kind(kind, "finish", nil, nil, result)
        end

        o.on_complete(result)
        return result
    end

    o.tick = o.render

    function o.stop()
        o.loop_scope()
        o.loop_scope = o.factory.delete({ name = "loop" })
    end

    ---@param get_data? fun():table|framework.appearance.data|nil 参数说明
    ---@return fun()
    function o.start(get_data)
        assert(get_data == nil or type(get_data) == "function", "appearance renderer start get_data must be a function")

        o.stop()
        o.factory.timer(function()
            local render_args = nil
            if get_data ~= nil then
                render_args = get_data()
            end
            o.render(render_args)
        end, o.loop_scope)

        return o.stop
    end

    o.on_update.add(function(update_args)
        o.render(update_args)
    end)

    metatable.callable(o, o.render)

    return o
end

return M
