---@class framework.unit
local M = require "..base"
local list = require "lib.list"

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o

    ---@type hook.add
    o.target_groups = o.factory.add()

    ---@type hook.computed
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
    
    ---@type hook.computed
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
    
    ---@type hook.computed
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
    
    ---@type hook.computed
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

    ---@param player? player 参数说明
    o.select = function(player)
        player = player or o.player()
        M.select(o.handle(), player.handle())
    end
end
