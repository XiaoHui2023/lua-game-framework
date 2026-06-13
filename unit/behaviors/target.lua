---@class models.unit
local g = require "..base"
local list = require "list"

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o

    ---@type hook.add 目标组<list<unit>>
    o.target_groups = o.factory.add()

    ---@type hook.computed 目标<unit>
    o.targets = o.factory.computed(function()
        ---@type list<unit>
        local us = list()
        ---@type list<list<unit>>
        local target_groups = o.target_groups()

        target_groups.for_each(
            ---@param target_group list<unit>
            function(target_group)
                target_group.for_each(function(unit)
                    us.append(unit)
                end)
            end
        )

        return us
    end)
    
    ---@type hook.computed 友方目标<list<unit>>
    o.friendly_targets = o.factory.computed(function()
        ---@type list<unit>
        local targets = o.targets()

        return targets.filter(
            ---@param target unit
            ---@return boolean
            function(target)
                ---@type faction
                local target_faction = target.faction()
                ---@type faction
                local self_faction = o.faction()
                return self_faction.is_friendly(target_faction)
            end
        )
    end)
    
    ---@type hook.computed 敌方目标<list<unit>>
    o.hostile_targets = o.factory.computed(function()
        ---@type list<unit>
        local targets = o.targets()

        return targets.filter(
            ---@param target unit
            ---@return boolean
            function(target)
                ---@type faction
                local target_faction = target.faction()
                ---@type faction
                local self_faction = o.faction()
                return self_faction.is_hostile(target_faction)
            end
        )
    end)
    
    ---@type hook.computed 中立目标<list<unit>>
    o.neutral_targets = o.factory.computed(function()
        ---@type list<unit>
        local targets = o.targets()

        return targets.filter(
            ---@param target unit
            ---@return boolean
            function(target)
                ---@type faction
                local target_faction = target.faction()
                ---@type faction
                local self_faction = o.faction()
                return self_faction.is_neutral(target_faction)
            end
        )
    end)

    -- 选中单位
    ---@param player? player 玩家
    o.select = function(player)
        player = player or o.player()
        g.select(o.handle(), player.handle())
    end
end