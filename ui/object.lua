---@class framework.ui
local M = require "framework.ui"
---@type lib.reactive
local reactive = require "lib.reactive"
local factory = reactive.factory
---@type framework.ui.apis
local apis = require ".apis"

---@class ui.options : factory.options
---@field alpha? integer 透明度，范围 0 到 255
---@field layer? ui.handle 所属 UI 层
---@field parent? ui 父级 UI
---@field type? ui.type UI 类型
---@field priority? integer 同级排序优先级
---@field progress? number 初始进度值，范围 0 到 1
---@field color? color 初始颜色
---@field align? ui.position 文本排列位置
---@field anchor? ui.anchor 初始锚点配置

---@param args? ui.options UI 创建参数
---@return ui UI 对象
M.create = function(args)
    args = args or {}
    args.image = args.image or ""
    args.alpha = args.alpha or 255
    args.layer = args.layer or M.LAYER.DEFAULT
    args.priority = args.priority or 0
    args.progress = args.progress or 1
    args.rotation = args.rotation or 0

    ---@class ui : factory
    local o = factory(args)

    o.set_class("ui")

    ---@type lib.reactive.ref
    o.parent = o.factory.set(args.parent)

    local parent_handle = args.parent and args.parent.handle() or args.layer

    ---@type lib.reactive.ref
    local create_api = apis.CREATE({
        type = args.type,
        parent_handle = parent_handle,
    })
    assert(create_api.handle ~= nil, "framework.ui.create requires runtime backend")
    o.handle = o.factory.set(create_api.handle)

    ---@type ui.type UI 类型
    o.type = args.type

    ---@type ui.layer
    o.layer = args.layer

    ---@type lib.reactive.ref
    o.priority = o.factory.set(args.priority)

    ---@type lib.reactive.ref
    o.alpha = o.factory.set(args.alpha)

    ---@type lib.reactive.ref
    o.image = o.factory.set(args.image)

    ---@type lib.reactive.ref
    o.progress = o.factory.set(args.progress)

    ---@type lib.reactive.ref
    o.rotation = o.factory.set(args.rotation)

    ---@type lib.reactive.ref
    o.color = o.factory.set(args.color)

    ---@type reactive.add<ui> children
    o.children = o.factory.add({
        prevent_duplicate = true,
    })
    local child_removers = {}

    ---@param child ui
    o.attach_child = function(child)
        if not child_removers[child] then
            child_removers[child] = o.children.add(child)
        end
    end

    ---@param child ui
    o.detach_child = function(child)
        local remove_child = child_removers[child]
        if remove_child then
            remove_child()
            child_removers[child] = nil
        end
    end

    ---@param parent ui?
    o.set_parent = function(parent)
        local old_parent = o.parent()
        if old_parent == parent then
            return
        end

        if old_parent and old_parent.remove_child then
            old_parent.remove_child(o)
        elseif old_parent and old_parent.detach_child then
            old_parent.detach_child(o)
        end

        o.parent.set(parent)
        apis.SET_PARENT({
            ui = o,
            parent_handle = parent and parent.handle() or o.layer,
        })

        if parent then
            if parent.attach_child then
                parent.attach_child(o)
            else
                parent.children.add(o)
            end
        end
    end

    if args.parent then
        if args.parent.attach_child then
            args.parent.attach_child(o)
        else
            args.parent.children.add(o)
        end
    end

    local function detach_from_parent()
        local parent = o.parent()
        if parent and parent.remove_child then
            parent.remove_child(o)
        elseif parent and parent.detach_child then
            parent.detach_child(o)
        end
        o.parent.set(nil)
    end

    o.delete.add(
        function()
            detach_from_parent()
            apis.DELETE({ handle = o.handle() })
        end
    )

    M.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function ()
        M.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    apis.OBJECT_CREATED({ ui = o, options = args })
    -- 注册事件
    o.factory.register_hook_fields()

    apis.ON_CREATE({ ui = o })

    return o
end

return M
