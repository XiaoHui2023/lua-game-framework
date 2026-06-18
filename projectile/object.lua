---@type lib.tablex
local table = require "lib.tablex"
---@class framework.projectile
local M = require ".base"
local factory = require "lib.reactive".factory
---@type framework.projectile.apis
local apis = require ".apis"

M.ON_CREATE = apis.ON_CREATE
M.ON_DESTROY = apis.ON_DESTROY

---@class projectile.options: lib.reactive.factory.options
---@field effect? any
---@field owner? unit
---@field position? point
---@field facing? number
---@field height? number
---@field duration? number

---@param args? projectile.options
---@param ... projectile.options
---@return projectile
M.create = function(args, ...)
    args = table.merge(args, ...)
    args = args or {}
    args.name = args.name or M.DEFAULT_NAME
    args.effect = args.effect or M.DEFAULT_EFFECT
    args.owner = args.owner
    args.position = args.position or M.DEFAULT_POSITION
    args.facing = args.facing or M.DEFAULT_FACING
    args.height = args.height or M.DEFAULT_HEIGHT
    args.scale = args.scale or M.DEFAULT_SCALE
    args.duration = args.duration or M.DEFAULT_DURATION
    assert(args.effect ~= nil, "projectile.create requires effect")

    ---@class projectile: lib.reactive.factory
    local o = factory(args)
    o.set_class("projectile")

    o.effect = o.factory.set(args.effect)
    o.owner = o.factory.set(args.owner)
    o.effect_handle = o.factory.set(M.new(
        args.effect,
        args.position,
        args.facing,
        args.scale,
        args.height,
        args.duration
    ))
    o.destroy = function()
        o.delete()
    end

    M.HANDLE_TO_OBJECT[o.effect_handle()] = o

    o.delete.add(function()
        M.ON_DESTROY({ projectile = o })
    end)

    o.delete.add(function()
        M.HANDLE_TO_OBJECT[o.effect_handle()] = nil
    end)

    o.delete.add(function()
        M.remove(o.effect_handle())
    end)

    require ".behaviors"(o, args)

    M.ON_CREATE({ projectile = o })

    return o
end

return M
