---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.motion
local M = require "framework.motion.base"
---@type lib.reactive
local reactive = require "lib.reactive"

---@alias framework.motion.modifier.phase
---| "normal"
---| "post"

local VALID_PHASE = {
    normal = true,
    post = true,
}

---@param value any
---@param name string
local function assert_optional_function(value, name)
    assert(value == nil or type(value) == "function", "motion modifier " .. name .. " must be a function")
end

---@class framework.motion.modifier.options
---@field name? string
---@field enabled? boolean
---@field phase? framework.motion.modifier.phase
---@field priority? integer
---@field exclusive? boolean
---@field interrupt_previous? boolean 新增�?renderer 时是否打断已有修改器
---@field interrupts_previous? boolean 新增�?renderer 时是否打断已有修改器
---@field reset_before_start? boolean 打断已有修改器后，是否先触发高度复位再运行自�?---@field reset_on_interrupt? boolean 自己被打断时是否要求 renderer 触发高度复位
---@field reset_on_finish? boolean 自己正常结束时是否要�?renderer 在空闲时触发高度复位
---@field modify? fun(data:framework.motion.data)
---@field tick? fun(data:framework.motion.data)
---@field should_run? fun(data:framework.motion.data):boolean
---@field should_finish? fun(data:framework.motion.data,result:framework.motion.result):boolean
---@field on_active_interrupt? fun(reason:string, modifier:framework.motion.modifier, target:framework.motion.modifier)
---@field on_passive_interrupt? fun(reason:string, modifier:framework.motion.modifier, source?:framework.motion.modifier)
---@field on_interrupt? fun(reason:string, modifier:framework.motion.modifier, source?:framework.motion.modifier)

---@param args? framework.motion.modifier.options
---@return framework.motion.modifier
function M.modifier(args)
    args = args or {}
    local phase = args.phase or "normal"
    local priority = args.priority or 0
    local modify = args.modify or args.tick or function()
    end

    assert(VALID_PHASE[phase], "motion modifier phase must be normal or post")
    assert(type(priority) == "number", "motion modifier priority must be a number")
    assert(type(modify) == "function", "motion modifier modify must be a function")
    assert_optional_function(args.should_run, "should_run")
    assert_optional_function(args.should_finish, "should_finish")
    assert_optional_function(args.on_active_interrupt, "on_active_interrupt")
    assert_optional_function(args.on_passive_interrupt, "on_passive_interrupt")
    assert_optional_function(args.on_interrupt, "on_interrupt")

    ---@class framework.motion.modifier : framework.motion.modifier.options
    local o = {
        name = args.name or "",
        enabled = args.enabled ~= false,
        phase = phase,
        priority = priority,
        exclusive = args.exclusive or false,
        interrupt_previous = args.interrupt_previous or args.interrupts_previous or false,
        interrupts_previous = args.interrupt_previous or args.interrupts_previous or false,
        reset_before_start = args.reset_before_start or false,
        reset_on_interrupt = args.reset_on_interrupt or false,
        reset_on_finish = args.reset_on_finish or false,
        finished = false,
        interrupted = false,
    }

    o.modify = modify
    o.tick = modify
    o.should_run = args.should_run or function()
        return true
    end
    o.should_finish = args.should_finish or function()
        return false
    end

    o.delete = reactive.once_event({ name = o.name .. ".delete" })
    o.before_modify = reactive.event({ name = o.name .. ".before_modify" })
    o.after_modify = reactive.event({ name = o.name .. ".after_modify" })
    o.after_render = reactive.event({ name = o.name .. ".after_render" })
    o.on_finish = reactive.once_event({ name = o.name .. ".finish" })
    o.on_active_interrupt = reactive.event({ name = o.name .. ".active_interrupt" })
    o.on_passive_interrupt = reactive.once_event({ name = o.name .. ".passive_interrupt" })
    o.on_interrupt = o.on_passive_interrupt

    if args.on_active_interrupt ~= nil then
        o.on_active_interrupt.add(args.on_active_interrupt)
    end
    if args.on_passive_interrupt ~= nil then
        o.on_passive_interrupt.add(args.on_passive_interrupt)
    end
    if args.on_interrupt ~= nil then
        o.on_interrupt.add(args.on_interrupt)
    end

    ---@param data framework.motion.data
    ---@return boolean
    function o.run(data)
        if o.finished or o.interrupted then
            return false
        end
        if not o.enabled then
            return false
        end
        if not o.should_run(data) then
            return false
        end

        o.before_modify(data)
        o.modify(data)
        o.after_modify(data)
        return true
    end

    ---@param result framework.motion.result
    function o.complete(result)
        if o.finished or o.interrupted then
            return
        end
        o.after_render(result)
        if o.should_finish(result.data, result) then
            o.finished = true
            o.on_finish(result)
            o.delete()
        end
    end

    ---@param reason? string
    ---@param target framework.motion.modifier
    function o.active_interrupt(reason, target)
        if o.finished or o.interrupted then
            return
        end
        o.on_active_interrupt(reason or "active_interrupt", o, target)
    end

    ---@param reason? string
    ---@param source? framework.motion.modifier
    function o.passive_interrupt(reason, source)
        if o.finished or o.interrupted then
            return
        end
        o.interrupted = true
        o.on_passive_interrupt(reason or "passive_interrupt", o, source)
        o.delete()
    end

    o.interrupt = o.passive_interrupt

    ---@param renderer framework.motion.renderer
    ---@return fun()
    function o.inject(renderer)
        return renderer.add(o)
    end

    o.attach = o.inject

    metatable.callable(o, o.run)

    return o
end

return M
