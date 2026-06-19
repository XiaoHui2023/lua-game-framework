---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o ui 需要挂接通用响应逻辑的 UI 对象
return function(o)
    -- 透明度
    o.alpha.wrap_set(function(al)
        al = al > 255 and 255 or al
        al = al < 0 and 0 or al
        return al
    end)
    o.alpha.on_change.add(function(al, old_al)
        -- 设置
        apis.SET_ALPHA({ handle = o.handle(), alpha = al })

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
        apis.SET_IMAGE({ ui = o, image = image })
    end)

    -- 进度
    o.progress.on_change.add(function(progress)
        if o.type ~= "progress_ring" and o.type ~= "progress_bar" then
            return
        end
        apis.SET_PROGRESS({ ui = o, progress = progress })
    end)

    -- 旋转
    o.rotation.on_change.add(function(rotation)
        apis.SET_ROTATION({ ui = o, rotation = rotation })
    end)

    -- 颜色
    o.color.on_change.add(function(color)
        if not color then
            return
        end
        apis.SET_IMAGE_COLOR({ ui = o, color = color })
    end)
end
