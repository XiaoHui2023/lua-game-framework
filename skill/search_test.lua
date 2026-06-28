local spatial = require "framework.spatial"
local target = require "framework.target"
local faction = require "framework.faction"
local skill = require "framework.skill"
local geometry = require "lib.mathx.geometry"

local function assert_same(actual, expected, message)
    assert(actual == expected, string.format("%s: expected %s, got %s", message, tostring(expected), tostring(actual)))
end

local red = faction.create({ name = "red" })
local blue = faction.create({ name = "blue" })
red.hostile_with(blue)

local world = spatial.create_world({ cell_size = 64 })
local caster_body = spatial.create_body({
    position = { x = 0, y = 0 },
    collision_radius = 8,
})
local caster = target.create({
    body = caster_body,
    kind = "unit",
    tags = { hero = true },
    faction = red,
})
local enemy_body = spatial.create_body({
    position = { x = 30, y = 0 },
    collision_radius = 8,
})
local enemy = target.create({
    body = enemy_body,
    kind = "unit",
    tags = { selectable = true },
    faction = blue,
})

world.add(caster_body)
world.add(enemy_body)

local target_rule = skill.create_target({
    context = { targetable = caster },
    world = world,
    shape = geometry.circle({ x = 0, y = 0 }, 80),
    relation = "enemy",
    kinds = { "unit" },
})

local hits = target_rule.search()
assert_same(#hits, 1, "skill target search should find enemy")
assert_same(hits[1], enemy, "skill target search should return enemy targetable")

print("framework.skill.search_test ok")
