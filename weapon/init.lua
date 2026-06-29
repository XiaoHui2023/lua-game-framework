---@class framework.weapon
local M = {}
package.loaded[...] = M

local factory_model = require "lib.reactive".factory

---@class framework.weapon.options: lib.reactive.factory.options
---@field name? string
---@field description? string
---@field icon? any
---@field hand_model? any
---@field unit? unit
---@field skills? skill.active[]
---@field passive_effects? table[]
---@field shortcuts? table<string, skill.active>

---@param args? framework.weapon.options
---@return framework.weapon.instance
function M.create(args)
    args = args or {}

    ---@class framework.weapon.instance: lib.reactive.factory
    local o = factory_model(args)
    o.factory.set_class("framework.weapon")

    o.factory.ref_field("display_name", args.name or "")
    o.factory.ref_field("description", args.description or "")
    o.factory.ref_field("icon", args.icon)
    o.factory.ref_field("hand_model", args.hand_model)
    o.factory.ref_field("unit", args.unit)
    o.factory.collection_field("skills")
    o.factory.collection_field("passive_effects")
    o.factory.event_field("on_equip")
    o.factory.event_field("on_unequip")
    o.factory.event_field("on_skill_cast")

    o.skills.wrap_add(function(skill)
        local context = skill.context()
        context.weapon = o
        context.unit = o.unit()
        skill.context.set(context)
        return skill
    end)

    function o.equip(unit)
        o.unit.set(unit)
        o.skills().for_each(function(skill)
            local context = skill.context()
            context.weapon = o
            context.unit = unit
            skill.context.set(context)
        end)
        o.on_equip(unit)
        return o
    end

    function o.unequip()
        local unit = o.unit()
        o.unit.set(nil)
        o.on_unequip(unit)
        return o
    end

    function o.get_primary_skill()
        return o.skills().first()
    end

    for _, skill in ipairs(args.skills or {}) do
        o.skills.add(skill)
    end
    for _, effect in ipairs(args.passive_effects or {}) do
        o.passive_effects.add(effect)
    end

    if args.unit ~= nil then
        o.equip(args.unit)
    end

    return o
end

M.new = M.create

require ".impl"

return M
