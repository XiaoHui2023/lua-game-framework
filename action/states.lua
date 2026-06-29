---@type framework.action
local action = require "framework.action"
local create_state = require "lib.state_machine.state"
local faction = require "framework.faction"
local unit_model = require "framework.unit"

local function source_from_context(context)
    context = context or {}
    return context.source or (context.request and context.request.caster)
end

local function get_position(unit)
    if unit == nil or type(unit.position) ~= "function" then
        return nil
    end
    return unit.position()
end

local function normalize_angle(degrees)
    degrees = degrees % 360
    if degrees < 0 then
        degrees = degrees + 360
    end
    return degrees
end

local function angle_delta(a, b)
    local delta = math.abs(normalize_angle(a) - normalize_angle(b))
    return math.min(delta, 360 - delta)
end

local function angle_to(a, b)
    return math.deg(math.atan(b.y - a.y, b.x - a.x))
end

local function is_in_fan(source, target, range, angle)
    local source_pos = get_position(source)
    local target_pos = get_position(target)
    if source_pos == nil or target_pos == nil then
        return false
    end

    local dx = (target_pos.x or 0) - (source_pos.x or 0)
    local dy = (target_pos.y or 0) - (source_pos.y or 0)
    if dx * dx + dy * dy > range * range then
        return false
    end

    local facing = 0
    if source ~= nil and type(source.facing) == "function" then
        facing = source.facing()
    end
    return angle_delta(facing, angle_to(source_pos, target_pos)) <= angle / 2
end

local function collect_units()
    local result = {}
    for _, unit in pairs(unit_model.HANDLE_TO_OBJECT) do
        result[#result + 1] = unit
    end
    return result
end

local function damage_value(source, options)
    local base = options.damage
    if base == nil and source ~= nil and type(source.damage) == "function" then
        base = source.damage()
    end
    base = base or 0
    return base * (options.damage_scale or 1)
end

action.register_state("call", function(options)
    return create_state({
        name = options.name or "call",
        machine = options.machine,
        data = options,
        on_run = function(context)
            if type(options.run) == "function" then
                options.run(context)
            end
            context.done()
        end,
    })
end)

action.register_state("delay", function(options)
    return create_state({
        name = options.name or "delay",
        machine = options.machine,
        data = options,
        on_entry = function(state)
            state:add_timer(options.duration or 0, function()
                state:done("delay_done")
            end)
        end,
    })
end)

action.register_state("melee_fan_damage", function(options)
    return create_state({
        name = options.name or "melee_fan_damage",
        machine = options.machine,
        data = options,
        on_run = function(context)
            local source = source_from_context(context.input)
            if source == nil or type(source.combat) ~= "function" then
                return context.done("no_source")
            end

            local range = options.range or 180
            local angle = options.angle or 90
            local targets = {}
            for _, target in ipairs(collect_units()) do
                if target ~= source
                    and is_in_fan(source, target, range, angle)
                    and faction.match_relation(source, target, options.relation or "enemy")
                then
                    targets[#targets + 1] = target
                end
            end

            for _, target in ipairs(targets) do
                source.combat({
                    target = target,
                    source = source,
                    inflictor = context.input.skill or context.input.weapon or source,
                    damage = damage_value(source, options),
                })
            end
            context.input.targets = targets
            context.done("damage_done")
        end,
    })
end)

return true
