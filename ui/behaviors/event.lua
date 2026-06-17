---@class framework.ui
local g = require "..base"
---@type lib.tablex
local table = require "lib.tablex"
---@type lib.reactive
local hook = require "lib.reactive"

---@param keys string[]
---@return ui.event.registry
local function create_event_registry(keys)
    ---@class ui.event.registry
    local registry = {}

    ---@type table<string, hook.event>
    local events = {}
    for _, key in ipairs(keys) do
        events[key] = hook.event()
    end

    function registry.get(key)
        return events[key]
    end

    function registry.add(key, callback)
        return events[key].add(callback)
    end

    ---@param obj hook.factory
    ---@param event_map table<string, hook.event>
    function registry.register(obj, event_map)
        for key, trigger in table.sorted_pairs(event_map) do
            local handler = registry.get(key)
            obj.delete.add(trigger.add(function(...)
                handler.run(obj, ...)
            end))
        end
    end

    return registry
end

---@class ui.options
---@field focusable? boolean 是否可聚焦，默认�?
---@field clickable? boolean 是否可点击，默认�?

---@alias ui.event.key
---| "left_up"
---| "left_down"
---| "right_up"
---| "right_down"
---| "focus"
---| "blur"
---| "click"

---@class ui.event.registry
---@field get fun(key:ui.event.key):hook.event 获取事件
---@field add fun(key:ui.event.key, callback:fun(ui:ui,...)):fun() 添加事件钩子
g.event_registry = create_event_registry({
    "left_up",
    "left_down",
    "right_up",
    "right_down",
    "focus",
    "blur",
    "click",
})

---@param o ui
---@param args ui.options
return function (o,args)
    args.focusable = args.focusable or false
    args.clickable = args.clickable or false

    ---@class ui
    o = o

    ---@type hook.set 鼠标焦点是否在UI上面
    o.focusable = o.factory.set(args.focusable)

    ---@type hook.set 是否可以点击
    o.clickable = o.factory.set(args.clickable)

    ---@type hook.event 鼠标左键抬起事件
    o.on_mouse_left_up = o.factory.event()

    ---@type hook.event 鼠标左键按下事件
    o.on_mouse_left_down = o.factory.event()

    ---@type hook.event 鼠标右键抬起事件
    o.on_mouse_right_up = o.factory.event()

    ---@type hook.event 鼠标右键按下事件
    o.on_mouse_right_down = o.factory.event()

    ---@type hook.event 聚焦事件
    o.on_focus = o.factory.event()

    ---@type hook.event 失去焦点事件
    o.on_blur = o.factory.event()

    ---@type hook.set 当前是否聚焦
    o.is_focused = o.factory.set(false)

    ---@type hook.event 点击事件
    o.on_click = o.factory.event()

    -- 注册事件
    o.delete.add(g.on_mouse_focus(o.handle(), function()
        if not o.focusable() then
            return
        end
        -- 需要可�?
        if not o.visible() then
            return
        end

        o.on_focus()
    end))
    o.delete.add(g.on_mouse_blur(o.handle(), function()
        if not o.focusable() then
            return
        end
        -- 需要可�?
        if not o.visible() then
            return
        end

        o.on_blur()
    end))
    o.delete.add(g.on_mouse_left_down(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 需要可�?
        if not o.visible() then
            return
        end

        o.on_mouse_left_down()
    end))
    o.delete.add(g.on_mouse_left_up(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 需要可�?
        if not o.visible() then
            return
        end

        o.on_mouse_left_up()
    end))
    o.delete.add(g.on_mouse_right_down(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 需要可�?
        if not o.visible() then
            return
        end

        o.on_mouse_right_down()
    end))
    o.delete.add(g.on_mouse_right_up(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 需要可�?
        if not o.visible() then
            return
        end

        o.on_mouse_right_up()
    end))

    -- 鼠标进入则聚�?
    o.on_focus.add(
        function()
            o.is_focused.set(true)
        end
    )

    -- 鼠标离开则取消聚�?
    o.on_blur.add(
        function()
            o.is_focused.set(false)
        end
    )

    -- 鼠标左键按下点击
    o.on_mouse_left_down.add(
        function()
            o.on_click()
        end
    )
    
    -- 注册事件
    g.event_registry.register(o,{
        left_up = o.on_mouse_left_up,
        left_down = o.on_mouse_left_down,
        right_up = o.on_mouse_right_up,
        right_down = o.on_mouse_right_down,
        focus = o.on_focus,
        blur = o.on_blur,
        click = o.on_click,
    })
end
