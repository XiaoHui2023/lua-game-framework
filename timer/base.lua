---@class framework.timer
---@field create fun(interval: number, func: fun()) 创建计时器
local g = {}

---@type number 中心计时器计时
g.COUNT = 0

return g