---@type framework.player
local g = require ".base"

require ".config"
g.apis = require ".apis"
require ".impl"

return g
