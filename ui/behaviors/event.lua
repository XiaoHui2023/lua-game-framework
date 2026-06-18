---@class framework.ui
local g = require "..base"
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
---@field get fun(key:ui.event.key):reactive.event 鑾峰彇浜嬩欢
---@field add fun(key:ui.event.key, callback:fun(ui:ui,...)):fun() 娣诲姞浜嬩欢閽╁瓙
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

    ---@type reactive.set 鼠标焦点是否在UI上面
    o.focusable = o.factory.set(args.focusable)

    ---@type reactive.set 是否可以点击
    o.clickable = o.factory.set(args.clickable)

    ---@type reactive.event 鼠标左键抬起事件
    o.on_mouse_left_up = o.factory.event()

    ---@type reactive.event 榧犳爣宸﹂敭鎸変笅浜嬩欢
    o.on_mouse_left_down = o.factory.event()

    ---@type reactive.event 鼠标右键抬起事件
    o.on_mouse_right_up = o.factory.event()

    ---@type reactive.event 榧犳爣鍙抽敭鎸変笅浜嬩欢
    o.on_mouse_right_down = o.factory.event()

    ---@type reactive.event 鑱氱劍浜嬩欢
    o.on_focus = o.factory.event()

    ---@type reactive.event 澶卞幓鐒︾偣浜嬩欢
    o.on_blur = o.factory.event()

    ---@type reactive.set 当前是否聚焦
    o.is_focused = o.factory.set(false)

    ---@type reactive.event 鐐瑰嚮浜嬩欢
    o.on_click = o.factory.event()

    -- 娉ㄥ唽浜嬩欢
    o.delete.add(g.on_mouse_focus(o.handle(), function()
        if not o.focusable() then
            return
        end
        -- 闇€瑕佸彲锟
        if not o.visible() then
            return
        end

        o.on_focus()
    end))
    o.delete.add(g.on_mouse_blur(o.handle(), function()
        if not o.focusable() then
            return
        end
        -- 闇€瑕佸彲锟
        if not o.visible() then
            return
        end

        o.on_blur()
    end))
    o.delete.add(g.on_mouse_left_down(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 闇€瑕佸彲锟
        if not o.visible() then
            return
        end

        o.on_mouse_left_down()
    end))
    o.delete.add(g.on_mouse_left_up(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 闇€瑕佸彲锟
        if not o.visible() then
            return
        end

        o.on_mouse_left_up()
    end))
    o.delete.add(g.on_mouse_right_down(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 闇€瑕佸彲锟
        if not o.visible() then
            return
        end

        o.on_mouse_right_down()
    end))
    o.delete.add(g.on_mouse_right_up(o.handle(), function()
        if not o.clickable() then
            return
        end
        -- 闇€瑕佸彲锟
        if not o.visible() then
            return
        end

        o.on_mouse_right_up()
    end))

    -- 榧犳爣杩涘叆鍒欒仛锟
    o.on_focus.add(
        function()
            o.is_focused.set(true)
        end
    )

    -- 榧犳爣绂诲紑鍒欏彇娑堣仛锟
    o.on_blur.add(
        function()
            o.is_focused.set(false)
        end
    )

    -- 榧犳爣宸﹂敭鎸変笅鐐瑰嚮
    o.on_mouse_left_down.add(
        function()
            o.on_click()
        end
    )
    
    -- 娉ㄥ唽浜嬩欢
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
