---@class framework.timer
---@field apis framework.timer.apis 计时器 callback API 表
---@field loop fun(interval: number?, func: timer.loop.func?): fun() 创建循环计时任务并返回取消函数
---@field delay fun(func: fun(), interval?: number): fun() 创建延迟任务并返回取消函数
---@field driver table reactive 使用的计时器驱动
local M = {}
package.loaded[...] = M

---@type number 中心计时器累计运行时间，单位秒
M.COUNT = 0

---@type framework.timer.apis
local apis = require ".apis"

M.apis = apis

require ".impl"
require ".core"

return M
