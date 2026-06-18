---@class framework.timer
---@field create fun(interval: number, func: fun()): fun() 创建计时器
---@field loop fun(interval: 字段说明
---@field delay fun(func: 字段说明
---@field driver table
local M = {}

---@type number 中心计时器计时
M.COUNT = 0

---@type framework.timer.apis
local apis = require ".apis"

M.apis = apis

M.create = function(interval, func)
    local api = apis.CREATE:new({ interval = interval, func = func })
    api:emit()
    assert(api.cancel ~= nil, "framework.timer.create requires runtime backend")
    return api.cancel
end

return M
