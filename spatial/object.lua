---@type framework.spatial
local spatial = require "framework.spatial"
---@type lib.reactive
local reactive = require "lib.reactive"
local collision = require ".collision"

local function same_position(position, old_position)
    return old_position ~= nil
        and position ~= nil
        and position.x == old_position.x
        and position.y == old_position.y
end

local function override_ref(ref, getter, setter)
    if type(getter) == "function" then
        ref.override_raw_get(getter)
    end
    if type(setter) == "function" then
        ref.override("set", function(_, old_set, value)
            setter(value)
            return old_set(value)
        end)
    end
end

---@class spatial.BodyOptions: lib.reactive.factory.options
---@field position? point
---@field facing? number
---@field height? number
---@field collision_radius? number
---@field get_position? fun(body: spatial.Body): point
---@field set_position? fun(position: point, body: spatial.Body)
---@field get_facing? fun(body: spatial.Body): number
---@field set_facing? fun(facing: number, body: spatial.Body)
---@field get_height? fun(body: spatial.Body): number
---@field set_height? fun(height: number, body: spatial.Body)
---@field get_collision_radius? fun(body: spatial.Body): number
---@field set_collision_radius? fun(radius: number, body: spatial.Body)

---@param o table
---@param args? spatial.BodyOptions
---@return spatial.Body
function spatial.setup_body(o, args)
    args = args or {}
    args.position = args.position or spatial.settings.DEFAULT_POSITION
    args.facing = args.facing or spatial.settings.DEFAULT_FACING
    args.height = args.height or spatial.settings.DEFAULT_HEIGHT
    args.collision_radius = args.collision_radius or spatial.settings.DEFAULT_COLLISION_RADIUS

    ---@class spatial.Body: lib.reactive.factory
    ---@field position lib.reactive.ref<point> World position.
    ---@field facing lib.reactive.ref<number> Facing angle in degrees.
    ---@field height lib.reactive.ref<number> Height above ground.
    ---@field collision_radius lib.reactive.ref<number> Circle collision radius.
    ---@field get_position fun(): point
    ---@field set_position fun(position: point)
    ---@field get_facing fun(): number
    ---@field set_facing fun(facing: number)
    ---@field get_height fun(): number
    ---@field set_height fun(height: number)
    ---@field get_collision_radius fun(): number
    ---@field set_collision_radius fun(radius: number)
    ---@field distance_to fun(target: spatial.Object|point): number
    ---@field is_in_range fun(position: point, radius: number): boolean
    ---@field is_colliding fun(target: spatial.Object): boolean
    o = o

    if o.factory == nil then
        reactive.factory(o)
    end
    o.factory.set_class(o.class_name or "spatial.Body")

    if o.position == nil then
        o.factory.ref_field("position", args.position)
    end
    if o.facing == nil then
        o.factory.ref_field("facing", args.facing)
    end
    if o.height == nil then
        o.factory.ref_field("height", args.height)
    end
    if o.collision_radius == nil then
        o.factory.ref_field("collision_radius", args.collision_radius)
    end

    o.position.wrap_equal(same_position)
    override_ref(o.position, args.get_position and function()
        return args.get_position(o)
    end, args.set_position and function(position)
        args.set_position(position, o)
    end)
    override_ref(o.facing, args.get_facing and function()
        return args.get_facing(o)
    end, args.set_facing and function(facing)
        args.set_facing(facing, o)
    end)
    override_ref(o.height, args.get_height and function()
        return args.get_height(o)
    end, args.set_height and function(height)
        args.set_height(height, o)
    end)
    override_ref(o.collision_radius, args.get_collision_radius and function()
        return args.get_collision_radius(o)
    end, args.set_collision_radius and function(radius)
        args.set_collision_radius(radius, o)
    end)

    function o.get_position()
        return o.position()
    end

    function o.set_position(position)
        o.position.set(position)
    end

    function o.get_facing()
        return o.facing()
    end

    function o.set_facing(facing)
        o.facing.set(facing)
    end

    function o.get_height()
        return o.height()
    end

    function o.set_height(height)
        o.height.set(height)
    end

    function o.get_collision_radius()
        return o.collision_radius()
    end

    function o.set_collision_radius(radius)
        o.collision_radius.set(radius)
    end

    function o.distance_to(target)
        local target_position = target.get_position and target.get_position() or target
        return collision.distance(o.get_position(), target_position)
    end

    function o.is_in_range(position, radius)
        return collision.object_intersects_circle(o, position, radius)
    end

    function o.is_colliding(target)
        return collision.objects_intersect(o, target)
    end

    return o
end

---@param args? spatial.BodyOptions
---@return spatial.Body
function spatial.create_body(args)
    local o = reactive.factory(args or {})
    return spatial.setup_body(o, args)
end

---@alias spatial.Object spatial.Body
---@alias spatial.ObjectOptions spatial.BodyOptions
spatial.setup_object = spatial.setup_body
spatial.create_object = spatial.create_body

return spatial
