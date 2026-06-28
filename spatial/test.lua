local spatial = require "framework.spatial"

local function assert_same(actual, expected, message)
    assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local function assert_true(value, message)
    assert(value, message)
end

local function assert_false(value, message)
    assert(not value, message)
end

local a = spatial.create_body({
    position = { x = 0, y = 0 },
    collision_radius = 10,
})
local b = spatial.create_body({
    position = { x = 15, y = 0 },
    collision_radius = 10,
})
local c = spatial.create_body({
    position = { x = 1000, y = 0 },
    collision_radius = 10,
})

assert_true(a.is_colliding(b), "near objects should collide")
assert_false(a.is_colliding(c), "far objects should not collide")

local stored_position = { x = 8, y = 9 }
local engine_object = spatial.create_body({
    get_position = function()
        return stored_position
    end,
    set_position = function(position)
        stored_position = position
    end,
})
engine_object.set_position({ x = 3, y = 4 })
assert_same(engine_object.get_position().x, 3, "overridden setter should update backing position x")
assert_same(engine_object.get_position().y, 4, "overridden setter should update backing position y")

local world = spatial.create_world({ cell_size = 64 })
world.add(a)
world.add(b)
world.add(c)

local hits = world.query_circle({ x = 0, y = 0 }, 20)
assert_same(#hits, 2, "circle query should return nearby objects")

c.set_position({ x = 5, y = 0 })
hits = world.query_object(a)
assert_same(#hits, 2, "query_object should find both nearby neighbours")

local geometry = require "lib.mathx.geometry"
hits = world.query_shape(geometry.rectangle({ x = 0, y = 0 }, 30, 20))
assert_same(#hits, 3, "query_shape should use shape bounds and exact filtering")

local group = spatial.create_group({ world = world })
local d = spatial.create_body({
    position = { x = 200, y = 0 },
    collision_radius = 20,
})
local outside_group = spatial.create_body({
    position = { x = 200, y = 0 },
    collision_radius = 20,
})
world.add(outside_group)
group.add(d)
hits = group.query_circle({ x = 200, y = 0 }, 1)
assert_same(#hits, 1, "group with world should query indexed objects")

print("framework.spatial.test ok")
