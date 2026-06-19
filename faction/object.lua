---@class framework.faction
local M = require "framework.faction"
local list = require "lib.list"
local factory = require("lib.reactive").factory

local VALID_STANCES = {
    neutral = true,
    friendly = true,
    hostile = true,
}

---@param stance faction.stance
local function assert_stance(stance)
    assert(VALID_STANCES[stance] == true, "invalid faction stance: " .. tostring(stance))
end

---@param stance_by_faction table<faction, faction.stance>
---@return table<faction, faction.stance>
local function copy_stance_map(stance_by_faction)
    local copied = {}
    for fac, stance in pairs(stance_by_faction) do
        copied[fac] = stance
    end
    return copied
end

---@class faction.options
---@field name string? 字段说明
---@field default_stance faction.stance? 字段说明

---@param args? faction.options 参数说明
---@return faction
M.create = function(args)
    args = args or {}
    args.name = args.name or ""
    args.default_stance = args.default_stance or "neutral"
    assert_stance(args.default_stance)

    ---@class faction : lib.reactive.factory
    ---@field name hook.set faction name.
    ---@field default_stance hook.set default stance to other factions.
    ---@field stance hook.set stance map keyed by target faction.
    local o = factory({
        name = args.name,
    })
    o.set_class("faction")

    o.delete.mount(M.POOL_OBJECT.add(o))

    ---@type hook.set<faction.stance>
    o.default_stance = o.factory.set(args.default_stance)

    ---@type hook.set<table<faction, faction.stance>>
    o.stance = o.factory.set({})

    ---@param fac faction target faction.
    ---@return faction.stance stance current stance.
    o.get_stance = function(fac)
        ---@type table<faction, faction.stance>
        local stance_by_faction = o.stance()
        return stance_by_faction[fac] or o.default_stance()
    end

    ---@param fac faction target faction.
    ---@param stance faction.stance next stance.
    ---@return nil
    o.set_stance = function(fac, stance)
        assert(fac ~= nil, "faction target must not be nil")
        assert_stance(stance)

        if o == fac then
            return
        end

        if o.get_stance(fac) == stance then
            return
        end

        ---@type table<faction, faction.stance>
        local stance_by_faction = copy_stance_map(o.stance())
        stance_by_faction[fac] = stance
        o.stance.set(stance_by_faction)
    end

    ---@param fac faction target faction.
    ---@return boolean is_friendly whether target is friendly.
    o.is_friendly = function(fac)
        if o == fac then
            return true
        end

        return o.get_stance(fac) == "friendly"
    end

    ---@param fac faction target faction.
    ---@return boolean is_neutral whether target is neutral.
    o.is_neutral = function(fac)
        if o == fac then
            return false
        end

        return o.get_stance(fac) == "neutral"
    end

    ---@param fac faction target faction.
    ---@return boolean is_hostile whether target is hostile.
    o.is_hostile = function(fac)
        if o == fac then
            return false
        end

        return o.get_stance(fac) == "hostile"
    end

    ---@return list<faction> allies friendly factions, including itself.
    o.ally = function()
        local facs = list()

        M.POOL_OBJECT().for_each(
            function(fac)
                if o.is_friendly(fac) then
                    facs.append(fac)
                end
            end
        )

        return facs
    end

    ---@return list<faction> enemies hostile factions.
    o.enemy = function()
        local facs = list()

        M.POOL_OBJECT().for_each(
            function(fac)
                if o.is_hostile(fac) then
                    facs.append(fac)
                end
            end
        )

        return facs
    end

    ---@return list<faction> neutrals neutral factions.
    o.neutral = function()
        local facs = list()

        M.POOL_OBJECT().for_each(
            function(fac)
                if o.is_neutral(fac) then
                    facs.append(fac)
                end
            end
        )

        return facs
    end

    ---@param fac faction target faction.
    ---@return nil
    o.set_friendly = function(fac)
        o.set_stance(fac, "friendly")
    end

    ---@param fac faction target faction.
    ---@return nil
    o.set_hostile = function(fac)
        o.set_stance(fac, "hostile")
    end

    ---@param fac faction target faction.
    ---@return nil
    o.set_neutral = function(fac)
        o.set_stance(fac, "neutral")
    end

    ---@param fac faction target faction.
    ---@return nil
    o.ally_with = function(fac)
        o.set_friendly(fac)
        fac.set_friendly(o)
    end

    ---@param fac faction target faction.
    ---@return nil
    o.hostile_with = function(fac)
        o.set_hostile(fac)
        fac.set_hostile(o)
    end

    ---@param fac faction target faction.
    ---@return nil
    o.neutral_with = function(fac)
        o.set_neutral(fac)
        fac.set_neutral(o)
    end

    return o
end

return M
