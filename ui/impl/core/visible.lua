---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type framework.event
local event = require "framework.event"

---@param o framework.ui 要装配显隐能力的 UI 对象
---@param args framework.ui.object_config UI 创建参数
return function (o,args)
    args.show = (args.show == nil) and false or args.show

    ---@type framework.ui
    o = o
    
    ---@type reactive.semaphore
    o.factory.hide_lock.semaphore()
    
    ---@type reactive.semaphore
    o.factory.weak_show.semaphore()

    ---@type lib.reactive.ref 基础显示<boolean>
    o.factory.show.set(args.show)

    ---@type reactive.computed 可见状态
    o.factory.visible.computed(function()
        if o.hide_lock.is_acquired() then
            return false
        end

        -- 上级不可见时自身也不可见。
        ---@type framework.ui
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

    -- 应用可见状态。
    o.visible.on_change.add(
        function(on)
            apis.SET_VISIBLE({ handle = o.handle(), visible = on })
        end
    )

    -- 绑定到帧更新
    o.visible.auto_update()
end
