---@class models.skill
local g = require ".base"

---@class skill.passive.options: skill.options

-- 创建被动技能
---@param args skill.passive.options
---@return skill.passive
g.create_passive = function(args)
    ---@class skill.passive: skill
    local o = g.new(args)
    o.set_class("skill.passive")

    -- 绑定事件
    ---@param event hook.event
    ---@param on fun(...):nil
    o.bind_event = function (event,on)
        o.delete.add(event.add(on))
    end

    return o
end