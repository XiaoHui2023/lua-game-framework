local appearance = require "framework.appearance"

local applied = {}
local resets = {}
local interrupted = 0
local finished = 0

local renderer = appearance.renderer({
    dt = 0.1,
    apply_change = function(args)
        applied[#applied + 1] = args.kind .. ":" .. tostring(args.value)
    end,
    reset_kind = function(args)
        resets[#resets + 1] = args.kind .. ":" .. args.reason
    end,
})

local red = renderer.create_modifier({
    name = "red",
    kind = appearance.KIND.COLOR,
    value = "red",
    reset_on_interrupt = true,
    on_interrupt = function()
        interrupted = interrupted + 1
    end,
})

renderer.render()
assert(applied[1] == "color:red", "color modifier should apply its value")
assert(red.interrupted == false, "red should still be active")

local blue = renderer.create_modifier({
    name = "blue",
    kind = appearance.KIND.COLOR,
    value = "blue",
    reset_before_start = true,
})

assert(red.interrupted == true, "same kind modifier should be interrupted")
assert(interrupted == 1, "interrupt callback should run once")
assert(resets[1] == "color:replace_previous", "replace should reset interrupted kind once")
assert(blue.interrupted == false, "replacement should stay active")

renderer.render()
assert(applied[#applied] == "color:blue", "replacement color should apply")

local head = renderer.create_modifier({
    name = "head_turn",
    kind = appearance.KIND.TURN_HEAD,
    value = 30,
})

local body = renderer.create_modifier({
    name = "body_turn",
    kind = appearance.KIND.TURN_BODY,
    value = 60,
})

renderer.render()
assert(head.interrupted == false, "head turn should not interrupt body turn")
assert(body.interrupted == false, "body turn should not interrupt head turn")

renderer.create_modifier({
    name = "head_turn_2",
    kind = appearance.KIND.TURN_HEAD,
    value = 45,
})

assert(head.interrupted == true, "same part turn should replace previous turn")
assert(body.interrupted == false, "different part turn should remain active")

renderer.create_modifier({
    name = "attack",
    kind = appearance.KIND.ANIMATION,
    value = "attack",
    once = true,
    reset_on_finish = true,
    on_finish = function()
        finished = finished + 1
    end,
})

renderer.render()
assert(finished == 1, "once modifier should finish after one render")
assert(resets[#resets] == "animation:finish", "reset_on_finish should reset modifier kind")

local timed = renderer.create_modifier({
    name = "flip_x",
    kind = appearance.KIND.FLIP_X,
    value = true,
    duration = 0.2,
    reset_on_finish = true,
})

renderer.render()
assert(timed.finished == false, "timed modifier should stay active before duration")
renderer.render()
assert(timed.finished == true, "timed modifier should finish after duration")
assert(resets[#resets] == "flip.x:finish", "timed finish should reset its kind")

renderer.interrupt_all({ reason = "unit_dead", reset = true })
assert(renderer.modifiers.empty(), "interrupt_all should remove all modifiers")
