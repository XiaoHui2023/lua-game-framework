---@class framework.timer
local g = require ".base"
---@type lib.debugx
local debugx = require "lib.debugx"

---@class timer
---@field time_reset number
---@field time_remain number
---@field run fun()
---@field is_running boolean

---@type timer[]
local CENTER_TIMER_LIST = {}

local CENTER_TIMER_INTERVAL = 0.01

g.create(CENTER_TIMER_INTERVAL, function()
    g.COUNT = g.COUNT + CENTER_TIMER_INTERVAL

    local index = 1
    while index <= #CENTER_TIMER_LIST do
        local timer = CENTER_TIMER_LIST[index]
        timer.time_remain = timer.time_remain - CENTER_TIMER_INTERVAL
        if timer.time_remain <= 0 then
            timer.time_remain = timer.time_reset
            xpcall(timer.run, function(err)
                debugx.error(err)
            end)
        end
        if CENTER_TIMER_LIST[index] == timer then
            index = index + 1
        end
    end
end)

---@param interval number
---@param func fun()
---@return fun()
local function add_center_timer(interval, func)
    ---@type timer
    local timer = {
        time_reset = interval,
        time_remain = interval,
        run = func,
        is_running = true,
    }
    table.insert(CENTER_TIMER_LIST, timer)

    return function()
        if not timer.is_running then
            return
        end
        timer.is_running = false
        for i = #CENTER_TIMER_LIST, 1, -1 do
            if CENTER_TIMER_LIST[i] == timer then
                table.remove(CENTER_TIMER_LIST, i)
                return
            end
        end
    end
end

---@alias timer.loop.func fun()

---@overload fun(func: timer.loop.func): function
---@overload fun(func: timer.loop.func, interval: number): function
---@overload fun(interval: number, func: timer.loop.func): function
---@param interval? number|fun()
---@param func timer.loop.func
---@return fun()
g.loop = function(interval, func)
    if type(interval) == "function" then
        func, interval = interval, func
    end
    ---@cast interval number
    ---@cast func timer.loop.func
    interval = interval or CENTER_TIMER_INTERVAL
    interval = interval < CENTER_TIMER_INTERVAL and CENTER_TIMER_INTERVAL or interval

    return add_center_timer(interval, function()
        func()
    end)
end

---@overload fun(func: fun()): function
---@overload fun(func: fun(), interval: number): function
---@overload fun(interval: number, func: fun()): function
---@param func fun()|number
---@param interval? number|fun()
---@return fun()
g.delay = function(func, interval)
    if type(interval) == "function" then
        func, interval = interval, func
    end
    ---@cast interval number
    ---@cast func timer.loop.func
    interval = interval or 0
    interval = interval < 0 and 0 or interval

    local delete
    delete = add_center_timer(interval, function()
        delete()
        func()
    end)
    return delete
end

require("lib.reactive").set_factory_timer_driver({
    register = function(trigger, interval)
        return g.loop(interval, trigger)
    end,
    destroy = function(delete)
        delete()
    end,
}, CENTER_TIMER_INTERVAL)

return g
