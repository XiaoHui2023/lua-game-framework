---@class framework.ui
local g = require ".base"
local factory = require "lib.reactive".factory
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.ui.apis
local apis = require ".apis"

---@type reactive.event 鍒涘缓浜嬩欢<ui>
g.ON_CREATE = apis.ON_CREATE

---@class ui.options : factory.options
---@field alpha
---@field layer
---@field parent
---@field type
---@field priority
---@field progress
---@field color
---@field align
---@field anchor

---@param args
---@return ui 鏉╂柨娲朥I鐎电
g.create = function(args)
    args = args or {}
    args.image = args.image or ""
    args.alpha = args.alpha or 255
    args.layer = args.layer or g.LAYER.DEFAULT
    args.priority = args.priority or 0
    args.progress = args.progress or 1
    args.rotation = args.rotation or 0

    ---@class ui : factory
    local o = factory(args)

    -- 鐠佸墽鐤嗙猾璇叉倳
    o.set_class("ui")

    ---@type reactive.set<ui.handle> 閸欍儲鐒
    o.handle = o.factory.set(g.new(args.type, args.layer))

    ---@type ui.type 缁
    o.type = args.type

    ---@type ui.layer 閸ユ儳鐪
    o.layer = args.layer

    ---@type reactive.set<integer> 娴兼ê鍘涚痪
    o.priority = o.factory.set(args.priority)

    ---@type reactive.set 閫忔槑搴
    o.alpha = o.factory.set(args.alpha)

    ---@type reactive.set 閸ュ墽澧
    o.image = o.factory.set(args.image)

    ---@type reactive.set<number> 杩涘害锛堢櫨鍒嗘瘮锛
    o.progress = o.factory.set(args.progress)

    ---@type reactive.set<number> 閺冨
    o.rotation = o.factory.set(args.rotation)

    ---@type reactive.set<color
    o.color = o.factory.set(args.color)

    ---@type reactive.add<ui> children
    o.children = o.factory.add()

    -- 缂佹垵鐣鹃崚鐘绘珟鐎电
    o.delete.add(
        function()
            g.delete(o.handle())
        end
    )

    -- 閸忋儱绨
    g.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function ()
        g.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    -- 濞夈劌鍞界悰灞艰礋
    require ".behaviors"(o,args)
    -- 娉ㄥ唽浜嬩欢
    o.factory.register_hook_fields()

    -- 鐟欙箑褰傞崚娑樼紦娴滃
    g.ON_CREATE({ ui = o })

    return o
end

return g
