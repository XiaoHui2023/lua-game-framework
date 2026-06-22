---@class framework.unit
local M = require "framework.unit"

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o

    ---@type hook.add<skill> 被动技能列表
    o.factory.skills.add()

    -- 添加技能时，绑定单位上下文
    o.skills.wrap_add(
        ---@param skill skill
        ---@return skill
        function(skill)
            ---@type skill.context
            local context = skill.context()
            -- 传递上下文
            context.unit = o
            skill.context.set(context)
            -- 绑定删除
            o.factory.capture("", skill)
            return skill
        end
    )
end
