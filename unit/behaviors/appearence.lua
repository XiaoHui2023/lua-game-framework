---@type framework.unit
local g = require "..base"

---@class unit.options
---@field model? model 模型
---@field color_enable? boolean 颜色使能
---@field color? color 颜色
---@field overlay_enable? boolean 覆盖使能
---@field overlay color? 覆盖
---@field outline_enable? boolean 描边使能
---@field outline? color 描边
---@field alpha? number 透明度
---@field animation_speed? number 动画速度
---@field scale? number 缩放
---@field scale_x? number X轴缩放
---@field scale_y? number Y轴缩放
---@field scale_z? number Z轴缩放

---@param o unit
---@param args unit.options
return function (o,args)
    args.model = args.model or g.DEFAULT_MODEL
    args.color_enable = args.color_enable or g.DEFAULT_COLOR_ENABLE
    args.color = args.color or g.DEFAULT_COLOR
    args.overlay_enable = args.overlay_enable or g.DEFAULT_OVERLAY_ENABLE
    args.overlay = args.overlay or g.DEFAULT_OVERLAY
    args.outline_enable = args.outline_enable or g.DEFAULT_OUTLINE_ENABLE
    args.outline = args.outline or g.DEFAULT_OUTLINE
    args.alpha = args.alpha or g.DEFAULT_ALPHA
    args.animation_speed = args.animation_speed or g.DEFAULT_ANIMATION_SPEED
    args.scale = args.scale or g.DEFAULT_SCALE
    args.scale_x = args.scale_x or args.scale or g.DEFAULT_SCALE_X
    args.scale_y = args.scale_y or args.scale or g.DEFAULT_SCALE_Y
    args.scale_z = args.scale_z or args.scale or g.DEFAULT_SCALE_Z

    ---@class unit
    o = o
    
    ---@type hook.set 模型
    o.model = o.factory.set(args.model)
    ---@type hook.set 透明度
    o.alpha = o.factory.set(args.alpha)
    ---@type hook.set 动画速度
    o.animation_speed = o.factory.set(args.animation_speed)
    ---@type hook.set 颜色使能
    o.color_enable = o.factory.set(args.color_enable)
    ---@type hook.set 颜色
    o.color = o.factory.set(args.color)
    ---@type hook.set 覆盖使能
    o.overlay_enable = o.factory.set(args.overlay_enable)
    ---@type hook.set 覆盖
    o.overlay = o.factory.set(args.overlay)
    ---@type hook.set 描边使能
    o.outline_enable = o.factory.set(args.outline_enable)
    ---@type hook.set 描边
    o.outline = o.factory.set(args.outline)
    ---@type hook.set 缩放
    o.scale = o.factory.set(args.scale)
    ---@type hook.set X轴缩放
    o.scale_x = o.factory.set(args.scale_x)
    ---@type hook.set Y轴缩放
    o.scale_y = o.factory.set(args.scale_y)
    ---@type hook.set Z轴缩放
    o.scale_z = o.factory.set(args.scale_z)

    -- 重载设置模型
    o.model.wrap_set(function(model)
        return model or o.model()
    end)
    o.model.on_change.add(function(model)
        g.replace_model(o.handle(), model.key)
    end)

    -- 设置颜色
    local function set_color(enable, co, alpha)
        g.set_color(o.handle(), enable, co, alpha)
    end
    
    -- 重载设置颜色使能
    o.color_enable.on_change.add(function(enable)
        set_color(enable, o.color(), o.alpha())
    end)
    
    -- 重载设置颜色
    o.color.wrap_set(function(co)
        return co or o.color() or {red=255,green=255,blue=255}
    end)
    o.color.wrap_equal(function(co, old_co)
        return old_co and co.red == old_co.red and co.green == old_co.green and co.blue == old_co.blue
    end)
    o.color.on_change.add(function(co)
        set_color(o.color_enable(), co, o.alpha())
    end)

    -- 重载设置透明度
    o.alpha.on_change.add(function(alpha)
        set_color(o.color_enable(), o.color(), alpha)
    end)

    -- 设置覆盖
    local function set_overlay(enable, co)
        g.set_overlay(o.handle(), enable, co)
    end

    -- 重载设置覆盖使能
    o.overlay_enable.on_change.add(function(enable)
        set_overlay(enable, o.overlay())
    end)

    -- 重载设置覆盖
    o.overlay.wrap_set(function(co)
        return co or o.overlay() or {red=255,green=255,blue=255}
    end)
    o.overlay.wrap_equal(function(co, old_co)
        return old_co and co.red == old_co.red and co.green == old_co.green and co.blue == old_co.blue
    end)
    o.overlay.on_change.add(function(co)
        set_overlay(o.overlay_enable(), co)
    end)

    -- 设置描边
    local function set_outline(enable, co)
        g.set_outline(o.handle(), enable, co)
    end

    -- 重载设置描边使能
    o.outline_enable.on_change.add(function(enable)
        set_outline(enable, o.outline())
    end)

    -- 重载设置描边
    o.outline.wrap_set(function(co)
        return co or o.outline() or {red=255,green=255,blue=255}
    end)
    o.outline.wrap_equal(function(co, old_co)
        return old_co and co.red == old_co.red and co.green == old_co.green and co.blue == old_co.blue
    end)
    o.outline.on_change.add(function(co)
        set_outline(o.outline_enable(), co)
    end)

    -- 缩放
    ---@param scale_x? number X轴缩放
    ---@param scale_y? number Y轴缩放
    ---@param scale_z? number Z轴缩放
    local function set_scale(scale_x, scale_y, scale_z)
        scale_x = scale_x or 1
        scale_y = scale_y or scale_x or 1
        scale_z = scale_z or scale_x or 1

        ---@type model
        local model = o.model() or {}
        local model_scale = model.scale or 1
        local real_scale_x = scale_x * (model.scale_x or model_scale)
        local real_scale_y = scale_y * (model.scale_y or model_scale)
        local real_scale_z = scale_z * (model.scale_z or model_scale)

        g.set_scale(o.handle(), real_scale_x, real_scale_y, real_scale_z)
    end

    -- 重载设置缩放
    o.scale.on_change.add(function(scale)
        set_scale(scale, scale, scale)
    end)

    -- 重载设置X轴缩放
    o.scale_x.on_change.add(function(scale_x)
        set_scale(scale_x, o.scale_y(), o.scale_z())
    end)

    -- 重载设置Y轴缩放
    o.scale_y.on_change.add(function(scale_y)
        set_scale(o.scale_x(), scale_y, o.scale_z())
    end)

    -- 重载设置Z轴缩放
    o.scale_z.on_change.add(function(scale_z)
        set_scale(o.scale_x(), o.scale_y(), scale_z)
    end)

    -- 重载设置动画速度
    o.animation_speed.on_change.add(function(speed)
        g.set_animation_speed(o.handle(), speed)
    end)

    -- 设置动画
    ---@param animation animation 动画
    ---@param speed number? 速度
    o.play_animation = function (animation, speed)
        g.play_animation(o.handle(), animation.name, speed, animation.start_time, animation.end_time, animation.loop, animation.reset_on_end)
    end

    -- 设置附加动画
    ---@param name string 动画名称
    o.set_alternate = function(name)
    end
end
