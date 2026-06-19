---@class framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type lib.tablex
local table = require "lib.tablex"
---@type lib.reactive
local reactive = require "lib.reactive"

---@param keys string[]
---@return ui.event.registry
local function create_event_registry(keys)
    ---@class ui.event.registry
    local registry = {}

    ---@type table<string, reactive.event>
    local events = {}
    for _, key in ipairs(keys) do
        events[key] = reactive.event()
    end

    function registry.get(key)
        return events[key]
    end

    function registry.add(key, callback)
        return events[key].add(callback)
    end

    ---@param obj reactive.factory
    ---@param event_map table<string, reactive.event>
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

---@param handle ui.handle
---@param event string
---@param func fun()
---@return fun()
local function register_mouse_event(handle, event, func)
    local api = apis.ON_MOUSE_EVENT({
        handle = handle,
        event = event,
        func = func,
    })
    return api.remove_func or function()
    end
end

---@class ui.options
---@field focusable
---@field clickable

---@alias ui.event.key
---| "left_up"
---| "left_down"
---| "right_up"
---| "right_down"
---| "focus"
---| "blur"
---| "click"

---@class ui.event.registry
---@field get fun(key:ui.event.key):reactive.event 按事件名获取响应式事件
---@field add fun(key:ui.event.key, callback:function):function 按事件名添加回调并返回删除函数
M.event_registry = create_event_registry({
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

    ---@type lib.reactive.ref 鼠标焦点是否在UI上面
    o.focusable = o.factory.set(args.focusable)

    ---@type lib.reactive.ref 是否可以点击
    o.clickable = o.factory.set(args.clickable)

    ---@type reactive.event
    o.on_mouse_left_up = o.factory.event()

    ---@type reactive.event
    o.on_mouse_left_down = o.factory.event()

    ---@type reactive.event
    o.on_mouse_right_up = o.factory.event()

    ---@type reactive.event
    o.on_mouse_right_down = o.factory.event()

    ---@type reactive.event
    o.on_focus = o.factory.event()

    ---@type reactive.event
    o.on_blur = o.factory.event()

    ---@type lib.reactive.ref 当前是否聚焦
    o.is_focused = o.factory.set(false)

    ---@type reactive.event
    o.on_click = o.factory.event()

    -- 注册事件
    o.delete.add(register_mouse_event(o.handle(), "鼠标-移入", function()
        if not o.focusable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_focus()
    end))
    o.delete.add(register_mouse_event(o.handle(), "鼠标-移出", function()
        if not o.focusable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_blur()
    end))
    o.delete.add(register_mouse_event(o.handle(), "左键-按下", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_left_down()
    end))
    o.delete.add(register_mouse_event(o.handle(), "左键-抬起", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_left_up()
    end))
    o.delete.add(register_mouse_event(o.handle(), "右键-按下", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_right_down()
    end))
    o.delete.add(register_mouse_event(o.handle(), "右键-抬起", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_right_up()
    end))

    o.on_focus.add(
        function()
            o.is_focused.set(true)
        end
    )

    o.on_blur.add(
        function()
            o.is_focused.set(false)
        end
    )

    o.on_mouse_left_down.add(
        function()
            o.on_click()
        end
    )
    
    -- 注册事件
    M.event_registry.register(o,{
        left_up = o.on_mouse_left_up,
        left_down = o.on_mouse_left_down,
        right_up = o.on_mouse_right_up,
        right_down = o.on_mouse_right_down,
        focus = o.on_focus,
        blur = o.on_blur,
        click = o.on_click,
    })
end
