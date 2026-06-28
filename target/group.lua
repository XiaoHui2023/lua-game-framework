---@type framework.target
local target = require "framework.target"
---@type lib.reactive
local reactive = require "lib.reactive"

---@class target.GroupOptions: lib.reactive.factory.options
---@field targets? target.Targetable[]

---@param args? target.GroupOptions
---@return target.Group
function target.create_group(args)
    args = args or {}

    ---@class target.Group: lib.reactive.factory
    ---@field targets lib.reactive.collection<target.Targetable>
    ---@field add fun(targetable: target.Targetable): function
    ---@field remove fun(targetable: target.Targetable)
    ---@field contains fun(targetable: target.Targetable): boolean
    local o = reactive.factory(args)
    o.factory.set_class("target.Group")
    o.factory.collection_field("targets", {
        prevent_duplicate = true,
        name = "targets",
    })

    local removers = {}

    function o.add(targetable)
        if removers[targetable] ~= nil then
            return removers[targetable]
        end
        local remove_from_collection = o.targets.add(targetable)
        local remove = function()
            if removers[targetable] == nil then
                return
            end
            removers[targetable] = nil
            remove_from_collection()
        end
        removers[targetable] = remove
        if targetable.factory ~= nil then
            targetable.factory.delete.add(remove)
        end
        return remove
    end

    function o.remove(targetable)
        local remove = removers[targetable]
        if remove ~= nil then
            remove()
        end
    end

    function o.contains(targetable)
        return removers[targetable] ~= nil
    end

    for _, targetable in ipairs(args.targets or {}) do
        o.add(targetable)
    end

    return o
end

return target
