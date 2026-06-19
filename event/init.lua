---@class framework.event
---@field apis framework.event.apis
local M = {}
package.loaded[...] = M

---@type framework.event.apis
local apis = require ".apis"

M.apis = apis
M.settings = require ".settings"

require ".types"
require ".impl"

return M
