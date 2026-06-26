---@type framework.projectile
local projectile = require "framework.projectile"
---@type framework.projectile.apis
local apis = require "..apis"

---@class projectile.options
---@field scale? number 整体缩放
---@field scale_x? number X 轴缩�?---@field scale_y? number Y 轴缩�?---@field scale_z? number Z 轴缩�?---@field animation_speed? number 动画速度倍率
---@field visible? boolean 是否显示

---@param o projectile
---@param args projectile.options
return function(o, args)
    args.scale = args.scale or projectile.settings.DEFAULT_SCALE
    args.scale_x = args.scale_x or args.scale
    args.scale_y = args.scale_y or args.scale
    args.scale_z = args.scale_z or args.scale
    args.animation_speed = args.animation_speed or projectile.settings.DEFAULT_ANIMATION_SPEED
    if args.visible == nil then
        args.visible = projectile.settings.DEFAULT_VISIBLE
    end

    o.factory.ref_field("scale", args.scale)
    o.factory.ref_field("scale_x", args.scale_x)
    o.factory.ref_field("scale_y", args.scale_y)
    o.factory.ref_field("scale_z", args.scale_z)
    o.factory.ref_field("animation_speed", args.animation_speed)
    o.factory.ref_field("visible", args.visible)

    local function set_scale(scale_x, scale_y, scale_z)
        apis.SET_SCALE({
            handle = o.effect_handle(),
            scale_x = scale_x,
            scale_y = scale_y,
            scale_z = scale_z,
        })
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
        apis.SET_ANIMATION_SPEED({ handle = o.effect_handle(), speed = speed })
    end)

    o.visible.on_change.add(function(visible)
        apis.SET_VISIBLE({ handle = o.effect_handle(), visible = visible })
    end)
end
