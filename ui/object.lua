---@class framework.ui
local g = require ".base"
local factory = require "lib.reactive".factory
---@type lib.reactive
local hook = require "lib.reactive"
---@type framework.ui.apis
local apis = require ".apis"

---@type hook.event 鍒涘缓浜嬩欢<ui>
g.ON_CREATE = apis.ON_CREATE

---@class ui.options : factory.options
---@field alpha? number 閫忔槑搴?---@field image? any 鍥剧墖璺緞
---@field layer? ui.layer 鍥惧眰
---@field parent? ui 鐖禪I
---@field type? ui.type 绫诲瀷
---@field priority? number 浼樺厛绾э紙灏忕殑浼樺厛绾э級
---@field progress? number 杩涘害锛堢櫨鍒嗘瘮锛?---@field rotation? number 鏃嬭浆锛堣搴︼級
---@field color? color? 棰滆壊
---@field align? ui.position 瀵归綈鏂瑰紡
---@field anchor? ui.anchor 鏂囨湰鐨勯敋鐐规病鏈夋柟浣嶄竴璇达紝鍙湁涓績銆傚疄闄呮柟浣嶅彇鍐充簬瀵归綈鏂瑰紡

---@param args? ui.options
---@return ui 杩斿洖UI瀵硅薄
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

    -- 璁剧疆绫诲悕
    o.set_class("ui")

    ---@type hook.set<ui.handle> 鍙ユ焺
    o.handle = o.factory.set(g.new(args.type, args.layer))

    ---@type ui.type 绫诲瀷
    o.type = args.type

    ---@type ui.layer 鍥惧眰
    o.layer = args.layer

    ---@type hook.set<integer> 浼樺厛绾?
    o.priority = o.factory.set(args.priority)

    ---@type hook.set 閫忔槑搴?
    o.alpha = o.factory.set(args.alpha)

    ---@type hook.set 鍥剧墖
    o.image = o.factory.set(args.image)

    ---@type hook.set<number> 杩涘害锛堢櫨鍒嗘瘮锛?
    o.progress = o.factory.set(args.progress)

    ---@type hook.set<number> 鏃嬭浆锛堣搴︼級
    o.rotation = o.factory.set(args.rotation)

    ---@type hook.set<color?> 棰滆壊锛堜负绌鸿〃绀轰笉璁剧疆锛?
    o.color = o.factory.set(args.color)

    ---@type hook.add<ui> children
    o.children = o.factory.add()

    -- 缁戝畾鍒犻櫎瀵硅薄
    o.delete.add(
        function()
            g.delete(o.handle())
        end
    )

    -- 鍏ュ簱
    g.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function ()
        g.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    -- 娉ㄥ唽琛屼负
    require ".behaviors"(o,args)
    -- 娉ㄥ唽浜嬩欢
    o.factory.register_hook_fields()

    -- 瑙﹀彂鍒涘缓浜嬩欢
    g.ON_CREATE({ ui = o })

    return o
end

return g
