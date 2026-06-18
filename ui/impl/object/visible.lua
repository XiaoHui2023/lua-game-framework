---@type framework.ui
local M = require "framework.ui.base"
---@type framework.event
local event = require "framework.event"

---@class ui.options
---@field show? boolean 初始是否显示

---@param o ui
---@param args ui.options
return function (o,args)
    args.show = (args.show == nil) and true or args.show

    ---@class ui
    o = o
    
    ---@type reactive.semaphore
    o.hide_lock = o.factory.semaphore()
    
    ---@type reactive.semaphore
    o.weak_show = o.factory.semaphore()

    ---@type lib.reactive.ref 基础显示<boolean>
    o.show = o.factory.set(args.show)

    ---@type reactive.computed 可见性
    o.visible = o.factory.computed(function()
        if o.hide_lock.is_acquired() then
            return false
        end

        -- 上级不可见
        ---@type ui
        local parent = o.parent()
        if parent and not parent.visible() then
            return false
        end

        if o.weak_show.is_acquired() then
            return true
        end

        -- 显示
        return o.show()
    end)

    -- 应用可见性
    o.visible.on_change.add(
        function(on)
            M.set_visible(o.handle(), on)
        end
    )

    -- 绑定到帧更新
    o.visible.auto_update()
end
