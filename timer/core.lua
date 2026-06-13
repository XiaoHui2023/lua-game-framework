---@class models.timer
local g = require ".base"
---@type m_debugx
local debugx = require "debugx"
local chain = require "utils.chain"

---@class timer
---@field time_reset number 时间重置
---@field time_remain number 剩余时间
---@field run fun() 运行函数
---@field is_runing boolean 是否运行

---@type utils.chain<timer> 中心计时器的库
local CENTER_TIMER_LIST = chain()

---@type number 中心计时器时间精度
local CENTER_TIMER_INTERVAL = 0.01

-- 中心计时器
g.create(CENTER_TIMER_INTERVAL, function ()
    -- 计数
    g.COUNT = g.COUNT + CENTER_TIMER_INTERVAL

    -- 遍历计时器
    CENTER_TIMER_LIST.for_each(
        ---@param timer timer
        function(timer)
            timer.time_remain = timer.time_remain - CENTER_TIMER_INTERVAL
            -- 计数清零，重置
            if timer.time_remain <= 0 then
                timer.time_remain = timer.time_reset
                xpcall(
                    timer.run,
                    function(err)
                        debugx.error(err)
                    end
                )
            end
        end
    )
end)

---向中心计时器添加一个循环执行的计时器
---@param interval number 时间间隔
---@param func fun() 函数
---@return fun() 删除函数
local function add_center_timer(interval, func)
    ---@type timer
    local timer = {
        time_reset = interval,
        time_remain = interval,
        run = func,
        is_runing = true,
    }
    return CENTER_TIMER_LIST.add(timer)
end

---@alias timer.loop.func fun()

---- 循环计时器
---@overload fun(func: timer.loop.func): function
---@overload fun(func: timer.loop.func, interval: number): function
---@overload fun(interval: number, func: timer.loop.func): function
---@param interval? number|fun() 间隔时间（秒）或要执行的函数
---@param func timer.loop.func 要执行的函数或间隔时间
---@return fun() 删除函数
g.loop = function(interval, func)
    if type(interval) == "function" then
        func, interval = interval, func
    end
    ---@cast interval number
    ---@cast func timer.loop.func
    interval = interval or CENTER_TIMER_INTERVAL
    interval = interval < CENTER_TIMER_INTERVAL and CENTER_TIMER_INTERVAL or interval

    return add_center_timer(
        interval,
        function()
            func()
        end
    )
end

---- 延迟一次性计时器
---@overload fun(func: fun()): function
---@overload fun(func: fun(), interval: number): function
---@overload fun(interval: number, func: fun()): function
---@param func fun()|number 要执行的函数或延迟时间
---@param interval? number|fun() 延迟时间（秒）或要执行的函数
---@return fun() 删除函数
g.delay = function(func, interval)
    if type(interval) == "function" then
        func, interval = interval, func
    end
    ---@cast interval number
    ---@cast func timer.loop.func
    interval = interval or 0
    interval = interval < 0 and 0 or interval

    -- 计时器
    local delete
    delete =
        add_center_timer(
            interval,
            function()
                delete()
                func()
            end
        )
    return delete
end

return g
