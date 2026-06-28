---@type framework.spatial
local spatial = require "framework.spatial"
---@type lib.reactive
local reactive = require "lib.reactive"
local collision = require ".collision"
local spatial_hash_grid = require "lib.mathx.spatial_hash_grid"

---@class spatial.WorldOptions: lib.reactive.factory.options
---@field cell_size? number
---@field index? spatial.SpatialIndex

---@class spatial.QueryOptions
---@field exclude? spatial.Body
---@field predicate? fun(body: spatial.Body): boolean
---@field refresh? boolean

---@param args? spatial.WorldOptions
---@return spatial.World
function spatial.create_world(args)
    args = args or {}

    ---@class spatial.World: lib.reactive.factory
    ---@field add fun(body: spatial.Body): function
    ---@field remove fun(body: spatial.Body)
    ---@field update_body fun(body: spatial.Body)
    ---@field update_object fun(body: spatial.Body)
    ---@field rebuild fun()
    ---@field query_circle fun(position: point, radius: number, options?: spatial.QueryOptions): spatial.Body[]
    ---@field query_shape fun(shape: table, options?: spatial.QueryOptions): spatial.Body[]
    ---@field query_point fun(position: point, options?: spatial.QueryOptions): spatial.Body[]
    ---@field query_object fun(body: spatial.Body, extra_radius?: number, options?: spatial.QueryOptions): spatial.Body[]
    local o = reactive.factory(args)
    o.factory.set_class("spatial.World")

    local index = args.index or spatial_hash_grid.create({
        cell_size = args.cell_size or spatial.settings.DEFAULT_CELL_SIZE,
        get_position = function(object)
            return object.get_position()
        end,
        get_radius = function(object)
            return object.get_collision_radius()
        end,
    })
    local objects = {}
    local removers = {}

    local function bind_object(object)
        local remove_callbacks = {}
        local function add_callback(ref)
            if ref ~= nil and ref.on_change ~= nil then
                remove_callbacks[#remove_callbacks + 1] = ref.on_change.add(function()
                    o.update_body(object)
                end)
            end
        end
        add_callback(object.position)
        add_callback(object.collision_radius)
        if object.factory ~= nil then
            remove_callbacks[#remove_callbacks + 1] = object.factory.delete.add(function()
                o.remove(object)
            end)
        end
        return function()
            for _, remove_callback in ipairs(remove_callbacks) do
                remove_callback()
            end
        end
    end

    function o.add(object)
        if objects[object] then
            return removers[object]
        end
        objects[object] = true
        index.insert(object)
        local unbind = bind_object(object)
        local remove = function()
            if not objects[object] then
                return
            end
            objects[object] = nil
            index.remove(object)
            unbind()
            removers[object] = nil
        end
        removers[object] = remove
        return remove
    end

    function o.remove(object)
        local remove = removers[object]
        if remove ~= nil then
            remove()
        end
    end

    function o.update_body(object)
        if objects[object] then
            index.update(object)
        end
    end

    o.update_object = o.update_body

    function o.rebuild()
        index.clear()
        for object in pairs(objects) do
            index.insert(object)
        end
    end

    local function accept_object(object, options)
        if options ~= nil and options.exclude == object then
            return false
        end
        if options ~= nil and options.predicate ~= nil and not options.predicate(object) then
            return false
        end
        return true
    end

    function o.query_circle(position, radius, options)
        options = options or {}
        if options.refresh then
            o.rebuild()
        end
        local result = {}
        index.visit_circle_candidates(position, radius, function(object)
            if accept_object(object, options) and collision.object_intersects_circle(object, position, radius) then
                result[#result + 1] = object
            end
        end)
        return result
    end

    function o.query_shape(shape, options)
        assert(type(shape) == "table" and type(shape.bounds) == "function", "spatial query_shape requires shape.bounds")
        assert(type(shape.intersects_circle) == "function", "spatial query_shape requires shape.intersects_circle")
        local bounds = shape.bounds()
        local center = bounds.position
        local radius = ((bounds.width * bounds.width + bounds.height * bounds.height) ^ 0.5) / 2
        options = options or {}
        local query_options = {}
        for key, value in pairs(options) do
            query_options[key] = value
        end
        local old_predicate = options.predicate
        query_options.predicate = function(body)
            if old_predicate ~= nil and not old_predicate(body) then
                return false
            end
            return shape.intersects_circle(body.get_position(), body.get_collision_radius())
        end
        return o.query_circle(center, radius, query_options)
    end

    function o.query_point(position, options)
        return o.query_circle(position, 0, options)
    end

    function o.query_object(object, extra_radius, options)
        options = options or {}
        options.exclude = options.exclude or object
        return o.query_circle(object.get_position(), object.get_collision_radius() + (extra_radius or 0), options)
    end

    o.factory.delete.add(function()
        for object in pairs(objects) do
            o.remove(object)
        end
        index.clear()
    end)

    return o
end

return spatial
