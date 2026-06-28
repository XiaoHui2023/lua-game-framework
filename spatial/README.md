# spatial

`framework.spatial` is the shared spatial body module for objects that have a
world position, facing angle, height, and collision radius.

It is meant to be composed by units, projectiles, visual effects, selection
tools, and barrage-style systems with many dynamic objects.

## Object

```lua
local spatial = require "framework.spatial"

local projectile_body = spatial.create_body({
    position = { x = 0, y = 0 },
    facing = 90,
    height = 60,
    collision_radius = 32,
})

projectile_body.set_position({ x = 100, y = 100 })
```

Engine-backed objects can override reads and writes:

```lua
unit.body = spatial.create_body({
    get_position = function()
        return unit.apis.GET_POSITION({ handle = unit.handle() }).position
    end,
    set_position = function(position)
        unit.apis.SET_POSITION({ handle = unit.handle(), position = position })
    end,
})
```

Projectiles can keep the default local reactive fields. Units can read position,
facing, and height from the game engine by passing getter functions.

Selection, type tags, faction, and skill target rules belong in
`framework.target`; `spatial` only indexes and queries bodies.

## World

`SpatialWorld` calls `lib.mathx.spatial_hash_grid` for indexed broadphase
queries. The grid is a mature
broadphase choice for large numbers of dynamic circular objects because moving an
object usually only updates the few cells around its collision radius.

```lua
local world = spatial.create_world({ cell_size = 128 })

world.add(projectile)
local hits = world.query_circle({ x = 100, y = 100 }, 200)
local selected = world.query_point(mouse_position)
```

Use `query_circle(position, radius)` for range checks, collision candidates, and
selection. Use `query_object(object)` to find nearby objects colliding with an
object.

For engine-backed objects whose coordinates can change without writing the
reactive `position` field, call `world.update_object(object)` after movement, or
pass `{ refresh = true }` to rebuild the index before a query.

## Group

`SpatialGroup` keeps a named collection of spatial objects. If created with a
world, adding an object also registers it for indexed collision queries.

```lua
local bullets = spatial.create_group({ world = world })
bullets.add(projectile)
```
