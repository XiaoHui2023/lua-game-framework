---@type framework.projectile
local projectile = require "framework.projectile"
---@type framework.projectile.apis
local apis = require "..apis"

---@class projectile.options
---@field position? point 投射物位�?---@field facing? number 投射物朝�?---@field height? number 投射物离地高�?
---@param o projectile
---@param args projectile.options
return function(o, args)
    args.position = args.position or projectile.settings.DEFAULT_POSITION
    args.facing = args.facing or projectile.settings.DEFAULT_FACING
    args.height = args.height or projectile.settings.DEFAULT_HEIGHT

    o.factory.ref_field("position", args.position)
    o.factory.ref_field("facing", args.facing)
    o.factory.ref_field("height", args.height)

    o.position.wrap_equal(function(position, old_position)
        return old_position and position.x == old_position.x and position.y == old_position.y
    end)

    o.position.on_change.add(function(position)
        apis.SET_POSITION({ handle = o.effect_handle(), position = position })
    end)

    o.facing.on_change.add(function(facing)
        apis.SET_FACING({ handle = o.effect_handle(), facing = facing })
    end)

    o.height.on_change.add(function(height)
        apis.SET_HEIGHT({ handle = o.effect_handle(), height = height })
    end)

    o.teleport = function(position)
        o.position.set(position)
    end
end
