---@class framework.event
---@field apis framework.event.apis
local M = {}
package.loaded[...] = M

---@type framework.event.apis
local apis = require ".apis"

M.apis = apis

require ".types"
require ".settings"
require ".impl"

return M
