---@class framework.target
---@field create fun(args?: target.TargetableOptions): target.Targetable
---@field create_group fun(args?: target.GroupOptions): target.Group
---@field filter table
---@field search fun(args: target.SearchOptions): target.Targetable[]
local M = {}
package.loaded[...] = M

M.filter = require ".filter"

require ".targetable"
require ".group"
require ".search"

return M
