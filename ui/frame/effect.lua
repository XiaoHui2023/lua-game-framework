---@class framework.ui
local g = require "..base"


---@class ui.effect.options : ui.options
---@field model any 模型路径
---@field type? ui.type 类型
---@field loop? boolean 是否循环

---@param args ui.effect.options
---@return ui.effect 返回对象
g.effect = function(args)
    args.model = args.model or nil
    args.loop = args.loop or false
    args.type = args.type or "effect"

    ---@class ui.effect : ui
    local o = g.create(args)

    ---@type hook.set 模型路径
    o.model = o.factory.set(args.model)

    ---@type hook.set 是否循环
    o.loop = o.factory.set(args.loop)

    -- 播放特效
    ---@param speed? number 速度
    o.play = function(speed)
        g.play_effect(o.handle(), o.model(), o.loop(),speed)
    end

    return o
end
