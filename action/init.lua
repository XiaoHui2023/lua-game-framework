---@class framework.action
local M = {}
package.loaded[...] = M

local state_machine = require "lib.state_machine"
local reactive = require "lib.reactive"

M.registry = state_machine.registry({ name = "framework.action.registry" })
M.active_runs = reactive.collection()
M.DEFAULT_UPDATE_DELTA = 1 / 30

---@param key string
---@param generator fun(options:table):lib.state_machine.state
function M.register_state(key, generator)
    M.registry:register(key, generator)
end

---@param tree table
---@param args? table
---@return lib.state_machine.state
function M.build_tree(tree, args)
    args = args or {}
    local builder = state_machine.builder({
        registry = M.registry,
        name = args.name or "action",
        group_name = args.group_name or "action_group",
    })
    return builder:build_tree(tree, {
        name = args.name or "action",
        machine_name = args.machine_name or args.name or "action",
        owner = args.owner,
    })
end

---@class framework.action.run.options
---@field name? string
---@field owner? any
---@field source? unit
---@field skill? skill.active
---@field weapon? framework.weapon.instance
---@field request? skill.cast_request
---@field tree? table
---@field state? lib.state_machine.state
---@field context? table
---@field on_done? fun(run:framework.action.run, reason?:string)

---@param args framework.action.run.options
---@return framework.action.run
function M.run(args)
    args = args or {}
    local context = args.context or {}
    context.owner = args.owner
    context.source = args.source
    context.skill = args.skill
    context.weapon = args.weapon
    context.request = args.request or {}

    local root = args.state
    if root == nil then
        root = M.build_tree(args.tree or {}, {
            name = args.name or "action",
            owner = context,
        })
    end

    ---@class framework.action.run
    local run = {
        root = root,
        context = context,
        done = false,
    }

    root.on_done.add(function(_, reason)
        run.done = true
        if type(args.on_done) == "function" then
            args.on_done(run, reason)
        end
    end)
    root.on_interrupted.add(function(_, reason)
        run.done = true
        if type(args.on_done) == "function" then
            args.on_done(run, reason)
        end
    end)

    run.remove = M.active_runs.add(run)
    root:start(context)
    return run
end

---@param dt? number
function M.update(dt)
    dt = dt or M.DEFAULT_UPDATE_DELTA
    M.active_runs().for_each(function(run)
        if run.done or run.root:is_done() then
            if run.remove ~= nil then
                run.remove()
                run.remove = nil
            end
        else
            run.root.machine:update(dt, run.context)
        end
    end)
end

require ".states"
require ".impl"

return M
