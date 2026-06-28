---@type framework.spatial
local spatial = require "framework.spatial"
---@type lib.reactive
local reactive = require "lib.reactive"

---@class spatial.GroupOptions: lib.reactive.factory.options
---@field objects? spatial.Body[]
---@field world? spatial.World

---@param args? spatial.GroupOptions
---@return spatial.Group
function spatial.create_group(args)
    args = args or {}

    ---@class spatial.Group: lib.reactive.factory
    ---@field objects lib.reactive.collection<spatial.Body>
    ---@field world spatial.World?
    ---@field add fun(body: spatial.Body): function
    ---@field remove fun(body: spatial.Body)
    ---@field query_circle fun(position: point, radius: number, options?: spatial.QueryOptions): spatial.Body[]
    ---@field query_shape fun(shape: table, options?: spatial.QueryOptions): spatial.Body[]
    local o = reactive.factory(args)
    o.factory.set_class("spatial.Group")
    o.factory.collection_field("objects", {
        prevent_duplicate = true,
        name = "objects",
    })
    o.world = args.world

    local removers = {}

    function o.add(object)
        if removers[object] ~= nil then
            return removers[object]
        end
        local remove_from_collection = o.objects.add(object)
        local remove_from_world = function()
        end
        if o.world ~= nil then
            remove_from_world = o.world.add(object)
        end
        local remove = function()
            if removers[object] == nil then
                return
            end
            removers[object] = nil
            remove_from_world()
            remove_from_collection()
        end
        removers[object] = remove
        if object.factory ~= nil then
            object.factory.delete.add(remove)
        end
        return remove
    end

    function o.remove(object)
        local remove = removers[object]
        if remove ~= nil then
            remove()
        end
    end

    function o.query_circle(position, radius, options)
        if o.world ~= nil then
            options = options or {}
            local query_options = {}
            for key, value in pairs(options) do
                query_options[key] = value
            end
            local old_predicate = options.predicate
            query_options.predicate = function(object)
                if removers[object] == nil then
                    return false
                end
                if old_predicate ~= nil then
                    return old_predicate(object)
                end
                return true
            end
            return o.world.query_circle(position, radius, query_options)
        end
        local result = {}
        o.objects().for_each(function(object)
            if object.is_in_range(position, radius) then
                result[#result + 1] = object
            end
        end)
        return result
    end

    function o.query_shape(shape, options)
        if o.world ~= nil then
            options = options or {}
            local query_options = {}
            for key, value in pairs(options) do
                query_options[key] = value
            end
            local old_predicate = options.predicate
            query_options.predicate = function(object)
                if removers[object] == nil then
                    return false
                end
                if old_predicate ~= nil then
                    return old_predicate(object)
                end
                return true
            end
            return o.world.query_shape(shape, query_options)
        end
        local result = {}
        o.objects().for_each(function(object)
            if shape.intersects_circle(object.get_position(), object.get_collision_radius()) then
                result[#result + 1] = object
            end
        end)
        return result
    end

    for _, object in ipairs(args.objects or {}) do
        o.add(object)
    end

    return o
end

return spatial
