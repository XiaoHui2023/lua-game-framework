local spatial = require "framework.spatial"
local target = require "framework.target"
local faction = require "framework.faction"
local geometry = require "lib.mathx.geometry"

local function assert_same(actual, expected, message)
    assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local red = faction.create({ name = "red" })
local blue = faction.create({ name = "blue" })
red.hostile_with(blue)

local world = spatial.create_world({ cell_size = 64 })

local hero_body = spatial.create_body({
    position = { x = 0, y = 0 },
    collision_radius = 12,
})
local hero = target.create({
    owner = { name = "hero" },
    body = hero_body,
    kind = "unit",
    tags = { hero = true, selectable = true },
    faction = red,
})

local enemy_body = spatial.create_body({
    position = { x = 20, y = 0 },
    collision_radius = 12,
})
local enemy = target.create({
    owner = { name = "enemy" },
    body = enemy_body,
    kind = "unit",
    tags = { summon = true, selectable = true },
    faction = blue,
})

local projectile_body = spatial.create_body({
    position = { x = 30, y = 0 },
    collision_radius = 8,
})
local projectile = target.create({
    owner = { name = "projectile" },
    body = projectile_body,
    kind = "projectile",
    tags = { bullet = true, selectable = true },
    faction = blue,
})

world.add(hero_body)
world.add(enemy_body)
world.add(projectile_body)

local selectable = target.create_group()
selectable.add(hero)
selectable.add(enemy)
selectable.add(projectile)

local hits = target.search({
    world = world,
    shape = geometry.rectangle({ x = 20, y = 0 }, 80, 40),
    source = hero,
    relation = "enemy",
    group = selectable,
    tags = { "selectable" },
    sort = "nearest",
})

assert_same(#hits, 2, "enemy search should include enemy unit and projectile")
assert_same(hits[1], enemy, "nearest enemy should be first")
assert_same(hits[2], projectile, "farther projectile should be second")

hits = target.search({
    world = world,
    shape = geometry.circle({ x = 0, y = 0 }, 100),
    kinds = { "projectile" },
})
assert_same(#hits, 1, "kind filter should select projectile only")
assert_same(hits[1], projectile, "projectile kind should match")

print("framework.target.test ok")
