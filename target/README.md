# target

`framework.target` describes objects that can be selected, searched, damaged, or
used as skill targets.

Spatial data stays in `framework.spatial.Body`. Target metadata is composed on
top:

```lua
unit.body = spatial.create_body(...)
unit.targetable = target.create({
    owner = unit,
    body = unit.body,
    kind = "unit",
    tags = { hero = true, selectable = true },
    faction = unit.faction,
})
```

Search combines geometry, spatial broadphase, type/tag/group filters, faction
relation, custom predicates, sorting, and limits:

```lua
target.search({
    world = world,
    shape = shape,
    source = caster.targetable,
    relation = "enemy",
    kinds = { "unit", "projectile" },
    tags = { selectable = true },
    sort = "nearest",
    limit = 3,
})
```
