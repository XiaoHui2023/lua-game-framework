---@type framework.ui
local g = require "..base"

---@param o ui
return function (o)
    -- 透明度
    o.alpha.wrap_set(function(al)
        al = al > 255 and 255 or al
        al = al < 0 and 0 or al
        return al
    end)
    o.alpha.on_change.add(function(al, old_al)
        -- 设置
        g.set_alpha(o.handle(), al)

        -- 下级也设置透明度
        o.children().for_each(function(child)
            child.alpha.set(al)
        end)
    end)

    -- 图片
    o.image.on_change.add(function(image)
        if image == "" or image == 0 or image == nil then
            return
        end
        g.set_image(o, image)
    end)

    -- 进度
    o.progress.on_change.add(function(progress)
        if o.type ~= "progress_ring" and o.type ~= "progress_bar" then
            return
        end
        g.set_progress(o, progress)
    end)

    -- 旋转
    o.rotation.on_change.add(function(rotation)
        g.set_rotation(o, rotation)
    end)

    -- 颜色
    o.color.on_change.add(function(color)
        if not color then
            return
        end
        g.set_image_color(o, color)
    end)
end