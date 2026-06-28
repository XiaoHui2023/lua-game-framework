---@type framework.target
local target = require "framework.target"
---@type lib.reactive
local reactive = require "lib.reactive"

local function normalize_tags(tags)
    local normalized = {}
    if tags == nil then
        return normalized
    end
    for key, value in pairs(tags) do
        if type(key) == "number" then
            normalized[value] = true
        elseif value then
            normalized[key] = true
        end
    end
    return normalized
end

---@class target.TargetableOptions: lib.reactive.factory.options
---@field owner? any
---@field body? spatial.Body
---@field kind? string
---@field tags? table<string, boolean>|string[]
---@field faction? faction

---@param args? target.TargetableOptions
---@return target.Targetable
function target.create(args)
    args = args or {}

    ---@class target.Targetable: lib.reactive.factory
    ---@field owner lib.reactive.ref<any>
    ---@field body lib.reactive.ref<spatial.Body>
    ---@field kind lib.reactive.ref<string>
    ---@field tags lib.reactive.ref<table<string, boolean>>
    ---@field faction lib.reactive.ref<faction>
    ---@field get_owner fun(): any
    ---@field get_body fun(): spatial.Body
    ---@field get_kind fun(): string
    ---@field has_tag fun(tag: string): boolean
    ---@field get_faction fun(): faction
    local o = reactive.factory(args)
    o.factory.set_class("target.Targetable")

    o.factory.ref_field("owner", args.owner)
    o.factory.ref_field("body", args.body)
    o.factory.ref_field("kind", args.kind or "object")
    o.factory.ref_field("tags", normalize_tags(args.tags))
    o.factory.ref_field("faction", args.faction)

    function o.get_owner()
        return o.owner()
    end

    function o.get_body()
        return o.body()
    end

    function o.get_kind()
        return o.kind()
    end

    function o.has_tag(tag)
        return o.tags()[tag] == true
    end

    function o.get_faction()
        return o.faction()
    end

    if args.body ~= nil then
        args.body.targetable = o
        if o.factory ~= nil then
            o.factory.delete.add(function()
                if args.body.targetable == o then
                    args.body.targetable = nil
                end
            end)
        end
    end

    return o
end

return target
