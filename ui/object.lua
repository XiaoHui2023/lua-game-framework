---@class models.ui
local g = require ".base"
local factory = require "models.factory"
---@type utils.hook
local hook = require "utils.hook"

---@type hook.event 创建事件<ui>
g.ON_CREATE = hook.event()

---@class ui.options : factory.options
---@field alpha? number 透明度
---@field image? any 图片路径
---@field layer? ui.layer 图层
---@field parent? ui 父UI
---@field type? ui.type 类型
---@field priority? number 优先级（小的优先）
---@field progress? number 进度（百分比）
---@field rotation? number 旋转（角度）
---@field color? color? 颜色
---@field align? ui.position 对齐方式
---@field anchor? ui.anchor 文本的锚点没有方位一说，只有中心。实际方位取决于对齐方式

---@param args? ui.options
---@return ui 返回UI对象
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

    -- 设置类名
    o.set_class("ui")

    ---@type hook.set<ui.handle> 句柄
    o.handle = o.factory.set(g.new(args.type, args.layer))

    ---@type ui.type 类型
    o.type = args.type

    ---@type ui.layer 图层
    o.layer = args.layer

    ---@type hook.set<integer> 优先级
    o.priority = o.factory.set(args.priority)

    ---@type hook.set 透明度
    o.alpha = o.factory.set(args.alpha)

    ---@type hook.set 图片
    o.image = o.factory.set(args.image)

    ---@type hook.set<number> 进度（百分比）
    o.progress = o.factory.set(args.progress)

    ---@type hook.set<number> 旋转（角度）
    o.rotation = o.factory.set(args.rotation)

    ---@type hook.set<color?> 颜色（为空表示不设置）
    o.color = o.factory.set(args.color)

    -- 绑定删除对象
    o.delete.add(
        function()
            g.delete(o.handle())
        end
    )

    -- 入库
    g.HANDLE_TO_OBJECT[o.handle()] = o
    o.delete.add(function ()
        g.HANDLE_TO_OBJECT[o.handle()] = nil
    end)

    -- 注册行为
    require ".behaviors"(o,args)
    -- 注册域
    o.factory.register_hook_fields()

    -- 触发创建事件
    g.ON_CREATE(o)

    return o
end

return g