---@type framework.target
local target = require "framework.target"
local filter = require ".filter"

local function distance_squared(source, targetable)
    if source == nil or source.get_body == nil then
        return 0
    end
    local source_body = source.get_body()
    local target_body = targetable.get_body()
    if source_body == nil or target_body == nil then
        return 0
    end
    local a = source_body.get_position()
    local b = target_body.get_position()
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    return dx * dx + dy * dy
end

local function sort_results(results, args)
    if args.sort == "nearest" then
        table.sort(results, function(a, b)
            return distance_squared(args.source, a) < distance_squared(args.source, b)
        end)
    elseif args.sort == "farthest" then
        table.sort(results, function(a, b)
            return distance_squared(args.source, a) > distance_squared(args.source, b)
        end)
    elseif type(args.sort) == "function" then
        table.sort(results, args.sort)
    end
end

---@class target.SearchOptions: target.FilterOptions
---@field world spatial.World
---@field shape? table
---@field position? point
---@field radius? number
---@field limit? integer
---@field sort? "nearest"|"farthest"|fun(a:target.Targetable,b:target.Targetable):boolean

---@param args target.SearchOptions
---@return target.Targetable[]
function target.search(args)
    assert(type(args) == "table", "target.search requires options")
    assert(args.world ~= nil, "target.search requires world")

    local candidates
    if args.shape ~= nil then
        candidates = args.world.query_shape(args.shape)
    else
        assert(args.position ~= nil and args.radius ~= nil, "target.search requires shape or position/radius")
        candidates = args.world.query_circle(args.position, args.radius)
    end

    local results = {}
    for _, body in ipairs(candidates) do
        local targetable = body.targetable
        if targetable ~= nil and filter.accept(targetable, args) then
            results[#results + 1] = targetable
        end
    end

    sort_results(results, args)
    if args.limit ~= nil and #results > args.limit then
        local limited = {}
        for index = 1, args.limit do
            limited[index] = results[index]
        end
        return limited
    end
    return results
end

return target
