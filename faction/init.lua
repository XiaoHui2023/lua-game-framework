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

---@alias faction.relation
---| "any"
---| "self"
---| "ally"
---| "enemy"
---| "neutral"
---| "not_self"

require ".object"

local function get_faction(value)
    if value == nil then
        return nil
    end
    if type(value.get_faction) == "function" then
        return value.get_faction()
    end
    if type(value.faction) == "function" then
        return value.faction()
    end
    return value.faction
end

---@param source any
---@param target any
---@param relation faction.relation|string
---@return boolean
function M.match_relation(source, target, relation)
    if relation == nil or relation == "any" then
        return true
    end
    if relation == "self" then
        return source == target
    end
    if relation == "not_self" then
        return source ~= target
    end

    local source_faction = get_faction(source)
    local target_faction = get_faction(target)
    if source_faction == nil or target_faction == nil then
        return false
    end

    if relation == "ally" then
        return source_faction.is_friendly(target_faction)
    end
    if relation == "enemy" then
        return source_faction.is_hostile(target_faction)
    end
    if relation == "neutral" then
        return source_faction.is_neutral(target_faction)
    end

    error("invalid faction relation: " .. tostring(relation), 2)
end

return M
