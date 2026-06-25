require "framework.ui.types"

local M = {}
package.loaded[...] = M

M.settings = require ".settings"
local state = require ".state"

require ".impl"

M.event_registry = state.event_registry

return M
