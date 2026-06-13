---@class models.ui
local g = require "..base"


---@class ui.model.options : ui.options
---@field model any 模型路径
---@field type? ui.type 类型

---@param args ui.model.options
---@return ui.model 返回对象
g.model = function(args)
    args.model = args.model or nil
    args.type = args.type or "model"

    ---@class ui.model : ui
    local o = g.create(args)

    ---@type hook.set 模型路径
    o.model = o.factory.set(args.model)
    o.model.on_change.add(
        function(model)
            if model == nil or model == "" then
                return
            end

            -- 应用
            g.set_model(o.handle(), model)
        end
    )

    -- 播放动画
    ---@param anima string 动画名
    ---@param is_loop? boolean 是否循环
    ---@param speed? number 速度
    o.play = function(anima, is_loop,speed)
        g.play_anima(o.handle(), anima, is_loop,speed)
    end

    return o
end
