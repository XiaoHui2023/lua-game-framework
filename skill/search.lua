---@class framework.skill
local M = require "framework.skill"
local target = require "framework.target"

local function context_source(context)
    context = context or {}
    if context.targetable ~= nil then
        return context.targetable
    end
    if context.unit ~= nil and context.unit.targetable ~= nil then
        return context.unit.targetable
    end
    if context.owner ~= nil and context.owner.targetable ~= nil then
        return context.owner.targetable
    end
    return nil
end

---@class skill.SearchOptions: target.SearchOptions
---@field context? skill.context

---@param args skill.SearchOptions
---@return target.Targetable[]
function M.search_targets(args)
    args = args or {}
    args.source = args.source or context_source(args.context)
    return target.search(args)
end

return M
