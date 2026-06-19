---@class framework.game
---@field apis framework.game.apis
local M = {}
package.loaded[...] = M
---@type framework.game.apis
local apis = require ".apis"

M.apis = apis

require ".settings"
require ".impl"

return M
