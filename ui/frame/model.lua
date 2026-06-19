---@class framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "..apis"


---@class ui.model.options : ui.options
---@field model any 模型路径
---@field type? ui.type UI 类型，默认是模型

---@param args ui.model.options
---@return ui.model 模型 UI 对象
M.model = function(args)
    args = args or {}
    args.model = args.model or nil
    args.type = args.type or "model"

    ---@class ui.model : ui
    local o = M.create(args)

    ---@type lib.reactive.ref 模型路径
    o.model = o.factory.set(args.model)
    o.model.on_change.add(
        function(model)
            if model == nil or model == "" then
                return
            end

            -- 应用
            apis.SET_MODEL({ handle = o.handle(), model = model })
        end
    )

    -- 播放动画
    ---@param anima string 动画名
    ---@param is_loop? boolean 是否循环播放动画
    ---@param speed? number 播放速度，未填时使用引擎默认速度
    o.play = function(anima, is_loop,speed)
        apis.PLAY_ANIMA({
            handle = o.handle(),
            anima = anima,
            is_loop = is_loop,
            speed = speed,
        })
    end

    return o
end
