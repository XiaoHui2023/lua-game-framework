---@type framework.ui.state
local state = require "framework.ui.state"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type lib.tablex
local table = require "lib.tablex"
---@type lib.reactive
local reactive = require "lib.reactive"

---@param keys framework.ui.event.key[] 需要创建的事件名列�?
local function setup_event_registry(keys, registry)
    ---@type table<framework.ui.event.key, reactive.event>
    local events = {}
    for _, key in ipairs(keys) do
        events[key] = reactive.event()
    end

    function registry.get(key)
        local event = events[key]
        assert(event ~= nil, "unknown ui event key: " .. tostring(key))
        return event
    end

    function registry.add(key, callback)
        return registry.get(key).add(callback)
    end

    ---@param obj framework.ui 需要挂接事件的 UI 对象

    function registry.register(obj, event_map)
        for key, trigger in table.sorted_pairs(event_map) do
            local handler = registry.get(key)
            obj.factory.delete.add(trigger.add(function(...)
                handler.run(obj, ...)
            end))
        end
    end

    return registry
end

---@param event string 运行时鼠标事件名
---@param func fun()
---@return fun() remove
local function register_mouse_event(handle, event, func)
    local api = apis.ON_MOUSE_EVENT({
        handle = handle,
        event = event,
        func = func,
    })
    return api.remove_func or function()
    end
end

setup_event_registry({
    "left_up",
    "left_down",
    "right_up",
    "right_down",
    "focus",
    "blur",
    "click",
}, state.event_registry)

---@param o framework.ui 要装配鼠标事件能力的 UI 对象
---@param args framework.ui.object_config UI 创建参数
return function (o,args)
    args.focusable = args.focusable or false
    args.clickable = args.clickable or false

    ---@type framework.ui
    o = o
    o.factory.ref_field("focusable", args.focusable)
    o.factory.ref_field("clickable", args.clickable)
    o.factory.event_field("on_mouse_left_up")
    o.factory.event_field("on_mouse_left_down")
    o.factory.event_field("on_mouse_right_up")
    o.factory.event_field("on_mouse_right_down")
    o.factory.event_field("on_focus")
    o.factory.event_field("on_blur")
    o.factory.ref_field("is_focused", false)
    o.factory.event_field("on_click")

    -- 注册事件
    o.factory.delete.add(register_mouse_event(o.handle(), "鼠标-移入", function()
        if not o.focusable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_focus()
    end))
    o.factory.delete.add(register_mouse_event(o.handle(), "鼠标-移出", function()
        if not o.focusable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_blur()
    end))
    o.factory.delete.add(register_mouse_event(o.handle(), "左键-按下", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_left_down()
    end))
    o.factory.delete.add(register_mouse_event(o.handle(), "左键-抬起", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_left_up()
    end))
    o.factory.delete.add(register_mouse_event(o.handle(), "右键-按下", function()
        if not o.clickable() then
            return
        end
        if not o.visible() then
            return
        end

        o.on_mouse_right_down()
    end))
    o.factory.delete.add(register_mouse_event(o.handle(), "右键-抬起", function()
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
    state.event_registry.register(o,{
        left_up = o.on_mouse_left_up,
        left_down = o.on_mouse_left_down,
        right_up = o.on_mouse_right_up,
        right_down = o.on_mouse_right_down,
        focus = o.on_focus,
        blur = o.on_blur,
        click = o.on_click,
    })
end
