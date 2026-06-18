---@type framework.projectile
local projectile = require "..base"

---@class projectile.options
---@field scale? number
---@field scale_x? number
---@field scale_y? number
---@field scale_z? number
---@field animation_speed? number
---@field visible? boolean

---@param o projectile
---@param args projectile.options
return function(o, args)
    args.scale = args.scale or projectile.DEFAULT_SCALE
    args.scale_x = args.scale_x or args.scale
    args.scale_y = args.scale_y or args.scale
    args.scale_z = args.scale_z or args.scale
    args.animation_speed = args.animation_speed or projectile.DEFAULT_ANIMATION_SPEED
    if args.visible == nil then
        args.visible = projectile.DEFAULT_VISIBLE
    end

    o.scale = o.factory.set(args.scale)
    o.scale_x = o.factory.set(args.scale_x)
    o.scale_y = o.factory.set(args.scale_y)
    o.scale_z = o.factory.set(args.scale_z)
    o.animation_speed = o.factory.set(args.animation_speed)
    o.visible = o.factory.set(args.visible)

    local function set_scale(scale_x, scale_y, scale_z)
        projectile.set_scale(o.effect_handle(), scale_x, scale_y, scale_z)
    end

    o.scale.on_change.add(function(scale)
        o.scale_x.set(scale)
        o.scale_y.set(scale)
        o.scale_z.set(scale)
    end)

    o.scale_x.on_change.add(function(scale_x)
        set_scale(scale_x, o.scale_y(), o.scale_z())
    end)

    o.scale_y.on_change.add(function(scale_y)
        set_scale(o.scale_x(), scale_y, o.scale_z())
    end)

    o.scale_z.on_change.add(function(scale_z)
        set_scale(o.scale_x(), o.scale_y(), scale_z)
    end)

    o.animation_speed.on_change.add(function(speed)
        projectile.set_animation_speed(o.effect_handle(), speed)
    end)

    o.visible.on_change.add(function(visible)
        projectile.set_visible(o.effect_handle(), visible)
    end)
end
