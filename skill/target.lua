---@class framework.skill
local M = require "framework.skill"
local factory_model = require "lib.reactive".factory

---@class skill.target.options: lib.reactive.factory.options
---@field shape? table
---@field world? spatial.World
---@field relation? faction.relation|string
---@field kinds? string[]|table<string, boolean>
---@field tags? string[]|table<string, boolean>
---@field group? target.Group
---@field limit? integer
---@field sort? string|function

---@param args? skill.target.options
---@return skill.target
M.create_target = function(args)
    args = args or {}

    ---@class skill.target: lib.reactive.factory
    local o = factory_model(args)
    o.factory.set_class("skill.target")

    o.factory.ref_field("context", args.context or {})
    o.factory.ref_field("world", args.world)
    o.factory.ref_field("shape", args.shape)
    o.factory.ref_field("relation", args.relation or "any")
    o.factory.ref_field("kinds", args.kinds)
    o.factory.ref_field("tags", args.tags)
    o.factory.ref_field("target_group", args.group)
    o.factory.ref_field("limit", args.limit)
    o.sort = args.sort

    ---@return target.Targetable[]
    o.search = function()
        return M.search_targets({
            context = o.context(),
            world = o.world(),
            shape = o.shape(),
            relation = o.relation(),
            kinds = o.kinds(),
            tags = o.tags(),
            group = o.target_group(),
            limit = o.limit(),
            sort = o.sort,
        })
    end

    return o
end
