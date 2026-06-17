---@type framework.ui
local g = require "..base"
---@type framework.event
local event = require "framework.event"

---@class ui.options
---@field show? boolean 是否显示（基础）

---@param o ui
---@param args ui.options
return function (o,args)
    args.show = (args.show == nil) and true or args.show

    ---@class ui
    o = o
    
    ---@type hook.semaphore 隐藏锁
    o.hide_lock = o.factory.semaphore()
    
    ---@type hook.semaphore 弱显示锁
    o.weak_show = o.factory.semaphore()

    ---@type hook.set 基础显示<boolean>
    o.show = o.factory.set(args.show)

    ---@type hook.computed 可见性
    o.visible = o.factory.computed(function()
        -- 锁定隐藏
        if o.hide_lock.is_acquired() then
            return false
        end

        -- 上级不可见
        ---@type ui
        local parent = o.parent()
        if parent and not parent.visible() then
            return false
        end

        -- 显示锁（弱）
        if o.weak_show.is_acquired() then
            return true
        end

        -- 显示
        return o.show()
    end)

    -- 应用可见性
    o.visible.on_change.add(
        function(on)
            g.set_visible(o.handle(), on)
        end
    )

    -- 绑定到帧更新
    o.visible.auto_update()
end
