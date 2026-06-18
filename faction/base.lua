---@class framework.faction
local g = {}
---@type lib.reactive
local reactive = require "lib.reactive"

---@type reactive.add faction object pool
g.POOL_OBJECT = reactive.collection()

---@alias faction.stance
---| "neutral"    # neutral stance
---| "friendly"   # friendly stance
---| "hostile"    # hostile stance

return g
