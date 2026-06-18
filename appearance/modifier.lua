---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.appearance
local M = require "framework.appearance.base"
---@type lib.reactive
local reactive = require "lib.reactive"

---@param value any
---@param name string
local function assert_optional_function(value, name)
    assert(value == nil or type(value) == "function", "unit visual modifier " .. name .. " must be a function")
end

---@class framework.appearance.modifier.options
---@field name? string
---@field kind? string
---@field enabled? boolean
---@field priority? integer
---@field exclusive? boolean
---@field replace_previous? boolean 新增到 renderer 时是否替换同 kind 的已有修改器
---@field interrupt_previous? boolean replace_previous 的兼容别名
---@field interrupts_previous? boolean replace_previous 的兼容别名
---@field reset_before_start? boolean 打断同 kind 修改器后，是否先触发该 kind 复位再运行自己
---@field reset_on_interrupt? boolean 自己被打断时是否要求 renderer 触发该 kind 复位
---@field reset_on_finish? boolean 自己正常结束时是否要求 renderer 触发该 kind 复位
---@field duration? number 持续时间；nil 表示不按时间结束
---@field once? boolean 是否运行一次后结束
---@field value? any 写入该 kind 的固定表现值
---@field apply? fun(data:framework.appearance.data, modifier:framework.appearance.modifier)
---@field modify? fun(data:framework.appearance.data, modifier:framework.appearance.modifier)
---@field tick? fun(data:framework.appearance.data, modifier:framework.appearance.modifier)
---@field should_run? fun(data:framework.appearance.data, modifier:framework.appearance.modifier):boolean
---@field should_finish? fun(data:framework.appearance.data,result:framework.appearance.result,modifier:framework.appearance.modifier):boolean
---@field on_finish? fun(result:framework.appearance.result, modifier:framework.appearance.modifier)
---@field on_interrupt? fun(reason:string, modifier:framework.appearance.modifier)

---@param args? framework.appearance.modifier.options
---@return framework.appearance.modifier
function M.modifier(args)
    args = args or {}
    local kind = args.kind or "default"
    local priority = args.priority or 0
    local apply = args.apply or args.modify or args.tick

    assert(type(kind) == "string" and kind ~= "", "appearance modifier kind must be a non-empty string")
    assert(type(priority) == "number", "appearance modifier priority must be a number")
    assert(apply == nil or type(apply) == "function", "appearance modifier apply must be a function")
    assert(args.duration == nil or type(args.duration) == "number", "appearance modifier duration must be a number")
    assert_optional_function(args.should_run, "should_run")
    assert_optional_function(args.should_finish, "should_finish")
    assert_optional_function(args.on_finish, "on_finish")
    assert_optional_function(args.on_interrupt, "on_interrupt")

    if apply == nil then
        apply = function(data, modifier)
            M.set_change(data, modifier.kind, modifier.value)
        end
    end

    local replace_previous = args.replace_previous
    if replace_previous == nil then
        replace_previous = args.interrupt_previous
    end
    if replace_previous == nil then
        replace_previous = args.interrupts_previous
    end
    if replace_previous == nil then
        replace_previous = true
    end

    ---@class framework.appearance.modifier : framework.appearance.modifier.options
    local o = {
        name = args.name or "",
        kind = kind,
        enabled = args.enabled ~= false,
        priority = priority,
        exclusive = args.exclusive or false,
        replace_previous = replace_previous,
        interrupt_previous = replace_previous,
        interrupts_previous = replace_previous,
        reset_before_start = args.reset_before_start or false,
        reset_on_interrupt = args.reset_on_interrupt or false,
        reset_on_finish = args.reset_on_finish or false,
        duration = args.duration,
        once = args.once or false,
        value = args.value,
        elapsed = 0,
        run_count = 0,
        finished = false,
        interrupted = false,
    }

    o.apply = apply
    o.modify = apply
    o.tick = apply
    o.should_run = args.should_run or function()
        return true
    end
    o.should_finish = args.should_finish or function(data, _, modifier)
        if modifier.once then
            return modifier.run_count > 0
        end
        if modifier.duration ~= nil then
            return modifier.elapsed >= modifier.duration
        end
        return false
    end

    o.delete = reactive.once_event({ name = o.name .. ".delete" })
    o.before_apply = reactive.event({ name = o.name .. ".before_apply" })
    o.after_apply = reactive.event({ name = o.name .. ".after_apply" })
    o.after_render = reactive.event({ name = o.name .. ".after_render" })
    o.on_finish = reactive.once_event({ name = o.name .. ".finish" })
    o.on_interrupt = reactive.once_event({ name = o.name .. ".interrupt" })

    if args.on_finish ~= nil then
        o.on_finish.add(args.on_finish)
    end
    if args.on_interrupt ~= nil then
        o.on_interrupt.add(args.on_interrupt)
    end

    ---@param data framework.appearance.data
    ---@return boolean
    function o.run(data)
        if o.finished or o.interrupted then
            return false
        end
        if not o.enabled then
            return false
        end
        if not o.should_run(data, o) then
            return false
        end

        o.before_apply(data, o)
        o.apply(data, o)
        o.after_apply(data, o)
        o.run_count = o.run_count + 1
        o.elapsed = o.elapsed + (data.dt or 0)
        return true
    end

    ---@param result framework.appearance.result
    function o.complete(result)
        if o.finished or o.interrupted then
            return
        end
        o.after_render(result, o)
        if o.should_finish(result.data, result, o) then
            o.finished = true
            o.on_finish(result, o)
            o.delete()
        end
    end

    ---@param reason? string
    function o.interrupt(reason)
        if o.finished or o.interrupted then
            return
        end
        o.interrupted = true
        o.on_interrupt(reason or "interrupt", o)
        o.delete()
    end

    ---@param renderer framework.appearance.renderer
    ---@return fun()
    function o.inject(renderer)
        return renderer.add(o)
    end

    o.attach = o.inject

    metatable.callable(o, o.run)

    return o
end

return M
