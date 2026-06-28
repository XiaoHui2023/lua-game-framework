---@type lib.metatablex
local metatablex = require "lib.metatablex"
---@type lib.reactive
local reactive = require "lib.reactive"
local constants = require "framework.damage.constants"
local create_phase = require "framework.damage.phase"
local side = require "framework.damage.side"
local resolver = require "framework.damage.resolver"
local effect = require "framework.damage.effect"

local M = {}

M.PHASE = constants.PHASE
M.phase = create_phase
M.modifier_phase = create_phase

---@alias framework.damage.modifier_mode
---| "chain"
---| "first"
---| "or"
---| "and"
---| "min"
---| "max"

---@class framework.damage.context
---@field damage? number ??????????? base_damage ? 0
---@field base_damage? number ???????????? damage
---@field source? any ??????
---@field target? any ??????
---@field has_control? boolean ????????
---@field has_cc? boolean has_control ?????
---@field tags? table<string, boolean> ??????
---@field data? table ???????

---@class framework.damage.state
---@field context framework.damage.context ???????
---@field base_damage number ?????
---@field damage number ?????
---@field hit boolean ????
---@field evaded boolean ?????
---@field damage_immune boolean ??????
---@field control_immune boolean ??????
---@field has_damage boolean ????????
---@field has_control boolean ????????
---@field stopped boolean ???????
---@field stop_reason? string ???????
---@field source? any ??????
---@field target? any ??????
---@field applied_modifiers framework.damage.applied_modifier[] ?????????

---@class framework.damage.result
---@field damage number ?????
---@field hit boolean ????
---@field evaded boolean ?????
---@field has_damage boolean ????????
---@field has_control boolean ????????
---@field damage_immune boolean ??????
---@field control_immune boolean ??????
---@field source? any ??????
---@field target? any ??????
---@field context framework.damage.context ???????
---@field applied_modifiers framework.damage.applied_modifier[] ?????????

---@class framework.damage.modifier
---@field callback fun(state:framework.damage.state,value?:any,modifier?:framework.damage.modifier):any? ???????
---@field condition? fun(state:framework.damage.state,modifier:framework.damage.modifier):boolean ???????
---@field priority? number ????????
---@field enabled? boolean ???????
---@field owner? any ??????
---@field source? any ??????
---@field name? string ?????
---@field uses? integer ??????
---@field remove_after_use? boolean ?????????
---@field delete? fun() ?????????

---@class framework.damage.applied_modifier
---@field phase string ??????????
---@field modifier framework.damage.modifier ???????
---@field before any ???????
---@field after any ???????

---@param args? lib.reactive.factory.options ??????
---@return framework.damage
function M.create(args)
    ---@class framework.damage: lib.reactive.factory
    ---@operator call(framework.damage.context):framework.damage.result
    local o = reactive.factory(args)
    o.factory.set_class("framework.damage")

    o.prepare = create_phase(M.PHASE.PREPARE, "chain")
    o.source = side.create_source()
    o.target = side.create_target()
    o.attacker = o.source
    o.defender = o.target

    o.phase_map = {
        prepare = o.prepare,
        hit = o.target.evasion,
        evasion = o.target.evasion,
        source_fixed = o.source.fixed,
        target_fixed = o.target.fixed,
        source_flat = o.source.flat,
        source_percent = o.source.percent,
        source_percentage = o.source.percent,
        target_percent = o.target.percent,
        target_percentage = o.target.percent,
        target_flat = o.target.flat,
        damage_immunity = o.target.damage_immunity,
        final = o.target.final,
        control = o.target.control_immunity,
        control_immunity = o.target.control_immunity,
        cc_immunity = o.target.control_immunity,
    }

    o.factory.delete.mount(o.prepare.delete)
    side.mount_delete(o, o.source)
    side.mount_delete(o, o.target)

    o.factory.event_field("on_start", { name = "on_start" })
    o.factory.event_field("on_prepare", { name = "on_prepare" })
    o.factory.event_field("on_hit", { name = "on_hit" })
    o.factory.event_field("on_miss", { name = "on_miss" })
    o.factory.event_field("on_damage_changed", { name = "on_damage_changed" })
    o.factory.event_field("on_damage_immunity", { name = "on_damage_immunity" })
    o.factory.event_field("on_final_immunity", { name = "on_final_immunity" })
    o.factory.event_field("on_control_immunity", { name = "on_control_immunity" })
    o.factory.event_field("on_finish", { name = "on_finish" })

    ---@param phase_name string
    ---@param modifier framework.damage.modifier
    ---@return fun()
    function o.add_modifier(phase_name, modifier)
        local phase = o.phase_map[phase_name]
        assert(phase ~= nil, "unknown damage phase: " .. tostring(phase_name))
        return phase.add_modifier(modifier)
    end

    ---@param options framework.damage.effect_options
    ---@return fun()
    function o.add_effect(options)
        return effect.add(o, options)
    end

    ---@param context? framework.damage.context ?????????
    ---@return framework.damage.result
    function o.run(context)
        return resolver.resolve(o, context)
    end

    metatablex.callable(o, o.run)

    return o
end

metatablex.callable(M, M.create)

return M
