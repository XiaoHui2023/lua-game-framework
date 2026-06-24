---@type framework.ui.state
local state = require "framework.ui.state"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type lib.tablex
local table = require "lib.tablex"
---@type lib.reactive
local reactive = require "lib.reactive"

---@param keys string[] 需要创建的事件名列表
---@return framework.ui.event.registry registry 事件注册表
local function create_event_registry(keys)
    ---@type framework.ui.event.registry
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

    ---@param obj reactive.factory 需要挂接事件的响应式对象
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

---@param handle framework.ui.handle 鼠标事件所属控件句柄
---@param event string 运行时鼠标事件名
---@param func fun() 事件触发回调
---@return fun remove 解绑函数
local function register_mouse_event(handle, event, func)
    local api = apis.ON_MOUSE_EVENT({
        handle = handle,
        event = event,
        func = func,
    })
    return api.remove_func or function()
    end
end

---@alias framework.ui.event.key UI 鼠标事件名
---| "left_up" 左键抬起
---| "left_down" 左键按下
---| "right_up" 右键抬起
---| "right_down" 右键按下
---| "focus" 鼠标进入
---| "blur" 鼠标离开
---| "click" 点击

---@class framework.ui.event.registry
---@field get fun(key:framework.ui.event.key):reactive.event 按事件名获取响应式事件
---@field add fun(key:framework.ui.event.key, callback:function):function 按事件名添加回调并返回删除函数
state.event_registry = create_event_registry({
    "left_up",
    "left_down",
    "right_up",
    "right_down",
    "focus",
    "blur",
    "click",
})

---@param o framework.ui 要装配鼠标事件能力的 UI 对象
---@param args framework.ui.object_config UI 创建参数
return function (o,args)
    args.focusable = args.focusable or false
    args.clickable = args.clickable or false

    ---@type framework.ui
    o = o

    ---@type lib.reactive.ref 鼠标焦点是否在UI上面
    o.factory.focusable.set(args.focusable)

    ---@type lib.reactive.ref 是否可以点击
    o.factory.clickable.set(args.clickable)

    ---@type reactive.event
    o.factory.on_mouse_left_up.event()

    ---@type reactive.event
    o.factory.on_mouse_left_down.event()

    ---@type reactive.event
    o.factory.on_mouse_right_up.event()

    ---@type reactive.event
    o.factory.on_mouse_right_down.event()

    ---@type reactive.event
    o.factory.on_focus.event()

    ---@type reactive.event
    o.factory.on_blur.event()

    ---@type lib.reactive.ref 当前是否聚焦
    o.factory.is_focused.set(false)

    ---@type reactive.event
    o.factory.on_click.event()

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
