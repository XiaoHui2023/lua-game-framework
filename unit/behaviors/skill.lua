---@class models.unit
local g = require "..base"

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o

    ---@type hook.add 被动技能<skill>
    o.skills = o.factory.add()

    -- 添加技能时，绑定单位
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
            o.children.add(skill)
            return skill
        end
    )
end