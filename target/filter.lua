local M = {}

local faction = require "framework.faction"

local function to_set(values)
    if values == nil then
        return nil
    end
    local set = {}
    for key, value in pairs(values) do
        if type(key) == "number" then
            set[value] = true
        elseif value then
            set[key] = true
        end
    end
    return set
end

---@class target.FilterOptions
---@field source? target.Targetable
---@field relation? string
---@field kinds? string[]|table<string, boolean>
---@field tags? string[]|table<string, boolean>
---@field exclude_tags? string[]|table<string, boolean>
---@field group? target.Group
---@field predicate? fun(targetable: target.Targetable): boolean

---@param targetable target.Targetable
---@param options? target.FilterOptions
---@return boolean
function M.accept(targetable, options)
    options = options or {}
    if options.group ~= nil and not options.group.contains(targetable) then
        return false
    end

    local kinds = to_set(options.kinds)
    if kinds ~= nil and not kinds[targetable.get_kind()] then
        return false
    end

    local required_tags = to_set(options.tags)
    if required_tags ~= nil then
        for tag in pairs(required_tags) do
            if not targetable.has_tag(tag) then
                return false
            end
        end
    end

    local excluded_tags = to_set(options.exclude_tags)
    if excluded_tags ~= nil then
        for tag in pairs(excluded_tags) do
            if targetable.has_tag(tag) then
                return false
            end
        end
    end

    if options.relation ~= nil and not faction.match_relation(options.source, targetable, options.relation) then
        return false
    end

    if options.predicate ~= nil and not options.predicate(targetable) then
        return false
    end

    return true
end

return M
