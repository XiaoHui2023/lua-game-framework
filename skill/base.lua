---@class framework.skill
local g = {}
local factory_model = require "lib.reactive".factory
local Stat = require ".stat"

---@class skill.context
---@field unit unit 鍗曚綅

---@alias skill.stat.kind
---| 'damage' 浼ゅ
---| 'damage_coef' 浼ゅ绯绘暟
---| 'range' 鑼冨洿
---| 'radius' 鍗婂緞
---| 'distance' 璺濈
---| 'cone_angle' 鎵囧舰瑙掑害
---| 'cooldown' 鍐峰嵈鏃堕棿
---| 'duration' 鎸佺画鏃堕棿

---@class skill.options: factory.options
---@field context? skill.context 涓婁笅锟?
-- 鍒涘缓鎶€锟?---@param args skill.options
---@return skill
g.new = function(args)
    args.context = args.context or {}

    ---@class skill: factory
    local o = factory_model(args)
    o.set_class("skill")

    ---@type hook.set 涓婁笅鏂噑kill.context>
    o.context = o.factory.set(args.context)

    ---@type hook.add 鏁版嵁<skill.stat>
    o.stats = o.factory.add()

    ---@type hook.add 瑙﹀彂鍣╯kill.trigger>
    o.triggers = o.factory.add()

    ---@type hook.add 鐩爣<skill.target>
    o.targets = o.factory.add()

    -- 鍒涘缓鏁版嵁
    ---@param args skill.stat.options
    ---@return skill.stat
    o.create_stat = function(args)
        ---@type skill.stat
        local stat = Stat(args)
        -- 娣诲姞
        o.stats.add(stat)
        o.factory.capture("", stat)
        return stat
    end

    o.triggers.wrap_add(
        ---@param trigger skill.trigger
        ---@return skill.trigger
        function(trigger)
            trigger.context.set(o.context())
            o.factory.capture("", trigger)
            return trigger
        end
    )

    -- 娣诲姞鐩爣鏃舵彁渚涗笂涓嬫枃
    o.targets.wrap_add(
        ---@param target skill.target
        ---@return skill.target
        function(target)
            target.context.set(o.context())
            o.factory.capture("", target)
            return target
        end
    )

    o.factory.register_hook_fields()

    return o
end

return g
