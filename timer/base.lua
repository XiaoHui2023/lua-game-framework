---@class framework.timer
---@field create fun(interval: number, func: fun()): fun() 创建计时器
---@field loop fun(interval: number, func: fun(interval?: number)): fun()
---@field delay fun(func: fun(), interval?: number): fun()
---@field driver table
local g = {}

---@type number 中心计时器计时
g.COUNT = 0

return g
