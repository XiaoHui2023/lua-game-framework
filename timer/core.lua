---@class framework.timer
local M = require ".base"
---@type lib.debugx
local debugx = require "lib.debugx"

---@class framework.timer.task
---@field interval_time number
---@field time_remain number
---@field run fun(interval_time?: 字段说明
---@field is_running boolean

---@type framework.timer.task[]
local CENTER_TIMER_LIST = {}

local CENTER_TIMER_INTERVAL = 0.01

local function assert_interval_time(interval_time)
    assert(type(interval_time) == "number" and interval_time > 0, "framework.timer interval must be positive")
end

local function normalize_loop_args(interval, func)
    if type(interval) == "function" then
        func, interval = interval, func
    end
    interval = interval or CENTER_TIMER_INTERVAL
    assert_interval_time(interval)
    if interval < CENTER_TIMER_INTERVAL then
        interval = CENTER_TIMER_INTERVAL
    end
    assert(type(func) == "function", "framework.timer callback must be a function")
    return interval, func
end

local function remove_center_timer(task)
    if not task.is_running then
        return
    end
    task.is_running = false
    for i = #CENTER_TIMER_LIST, 1, -1 do
        if CENTER_TIMER_LIST[i] == task then
            table.remove(CENTER_TIMER_LIST, i)
            return
        end
    end
end

local function add_center_timer(interval, func)
    ---@type framework.timer.task
    local task = {
        interval_time = interval,
        time_remain = interval,
        run = func,
        is_running = true,
    }
    table.insert(CENTER_TIMER_LIST, task)

    return function()
        remove_center_timer(task)
    end
end

M.create(CENTER_TIMER_INTERVAL, function()
    M.COUNT = M.COUNT + CENTER_TIMER_INTERVAL

    local index = 1
    while index <= #CENTER_TIMER_LIST do
        local task = CENTER_TIMER_LIST[index]
        task.time_remain = task.time_remain - CENTER_TIMER_INTERVAL
        if task.time_remain <= 0 then
            task.time_remain = task.interval_time
            xpcall(function()
                task.run(task.interval_time)
            end, function(err)
                debugx.error(err)
            end)
        end
        if CENTER_TIMER_LIST[index] == task then
            index = index + 1
        end
    end
end)


---@overload fun(func: timer.loop.func): function
---@overload fun(func: timer.loop.func, interval: number): function
---@overload fun(interval: number, func: timer.loop.func): function
---@param interval? number|timer.loop.func 参数说明
---@param func? timer.loop.func|number 参数说明
---@return fun()
function M.loop(interval, func)
    local interval_time, callback = normalize_loop_args(interval, func)
    return add_center_timer(interval_time, callback)
end

---@overload fun(func: fun()): function
---@overload fun(func: fun(), interval: number): function
---@overload fun(interval: number, func: fun()): function
---@param func fun()|number
---@param interval? number|fun() 参数说明
---@return fun()
function M.delay(func, interval)
    if type(interval) == "function" then
        func, interval = interval, func
    end
    ---@cast func fun()
    interval = interval or 0
    assert(type(interval) == "number" and interval >= 0, "framework.timer delay interval must be non-negative")

    local delete
    delete = add_center_timer(interval, function()
        delete()
        func()
    end)
    return delete
end

function M.interval_time()
    return CENTER_TIMER_INTERVAL
end

function M.get_default_interval_time()
    return CENTER_TIMER_INTERVAL
end

M.driver = {
    register = function(trigger, interval)
        return M.loop(interval, trigger)
    end,
    trigger = function(action, timer_model)
        action(timer_model.get_interval_time())
    end,
    destroy = function(delete)
        if type(delete) == "function" then
            delete()
        end
    end,
}

function M.inject_reactive(reactive)
    reactive = reactive or require "lib.reactive"
    reactive.set_timer_driver(M.driver, CENTER_TIMER_INTERVAL)
    reactive.set_factory_timer_driver(M.driver, CENTER_TIMER_INTERVAL)
end

M.inject_reactive()

return M
