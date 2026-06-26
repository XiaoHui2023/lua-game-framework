---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type framework.event
local event = require "framework.event"

local function is_callable(value)
    if type(value) == "function" then
        return true
    end
    local mt = getmetatable(value)
    return mt ~= nil and type(mt.__call) == "function"
end

local function read_parent_visible(parent)
    if parent == nil or not is_callable(parent.visible) then
        return true
    end
    return parent.visible()
end

---@param o framework.ui 要装配显隐能力的 UI 对象
---@param args framework.ui.object_config UI 创建参数
return function (o,args)
    args.show = (args.show == nil) and false or args.show


    ---@type framework.ui
    o = o
    
    ---@type reactive.semaphore
    o.factory.field("hide_lock").semaphore()
    
    ---@type reactive.semaphore
    o.factory.field("weak_show").semaphore()

    ---@type lib.reactive.ref 基础显示<boolean>
    o.factory.ref_field("show", args.show)

    ---@type reactive.computed 可见状�?    
    o.factory.computed_field("visible", function()
        if o.hide_lock.is_acquired() then
            return false
        end

        -- 上级不可见时自身也不可见�?        
        ---@type framework.ui
        local parent_factory = o.factory.parent()
        local parent = parent_factory and parent_factory.owner or nil
        if not read_parent_visible(parent) then
            return false
        end

        if o.weak_show.is_acquired() then
            return true
        end

        -- 显示
        return o.show()
    end)

    -- 应用可见状态�?    
    local function apply_visible(on)
        apis.SET_VISIBLE({ handle = o.handle(), visible = on })
    end

    o.visible.on_change.add(apply_visible)
    apply_visible(o.visible())

    -- 绑定到帧更新
    o.visible.auto_update()
end
