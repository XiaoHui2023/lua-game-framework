---@class framework.faction
local M = {}
package.loaded[...] = M
---@type lib.reactive
local reactive = require "lib.reactive"

---@type reactive.add faction object pool
M.POOL_OBJECT = reactive.collection()

---@alias faction.stance
---| "neutral"    # neutral stance
---| "friendly"   # friendly stance
---| "hostile"    # hostile stance

require ".object"

return M
