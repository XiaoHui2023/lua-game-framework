---@class framework.ui
local M = require "..base"


---@class ui.effect.options : ui.options
---@field model any 模型路径
---@field type? ui.type UI 类型，默认是特效
---@field loop? boolean 是否循环播放特效

---@param args ui.effect.options
---@return ui.effect 特效 UI 对象
M.effect = function(args)
    args.model = args.model or nil
    args.loop = args.loop or false
    args.type = args.type or "effect"

    ---@class ui.effect : ui
    local o = M.create(args)

    ---@type lib.reactive.ref 模型路径
    o.model = o.factory.set(args.model)

    ---@type lib.reactive.ref 是否循环
    o.loop = o.factory.set(args.loop)

    -- 播放特效
    ---@param speed? number 播放速度，未填时使用引擎默认速度
    o.play = function(speed)
        M.play_effect(o.handle(), o.model(), o.loop(),speed)
    end

    return o
end
