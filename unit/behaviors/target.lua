---@class framework.unit
local M = require "framework.unit"
---@type framework.unit.apis
local apis = require "..apis"
local list = require "lib.list"

---@param o unit
---@param args unit.options
return function (o,args)
    ---@class unit
    o = o

    ---@type hook.add
    o.factory.target_groups.add()

    ---@type hook.computed
    o.factory.targets.computed(function()
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
    o.factory.friendly_targets.computed(function()
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
    o.factory.hostile_targets.computed(function()
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
    o.factory.neutral_targets.computed(function()
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

    ---@param player? player 执行选择操作的玩家，省略时使用单位所属玩家
    o.select = function(player)
        player = player or o.player()
        apis.SELECT({ handle = o.handle(), player = player.handle() })
    end
end
