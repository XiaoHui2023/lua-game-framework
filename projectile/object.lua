---@type lib.tablex
local table = require "lib.tablex"
---@class framework.projectile
local M = require "framework.projectile"
local factory = require "lib.reactive".factory
---@type framework.projectile.apis
local apis = require ".apis"

---@class projectile.options: lib.reactive.factory.options
---@field effect? any 投射物使用的特效资源
---@field owner? unit 投射物所属单�?---@field position? point 初始位置
---@field facing? number 初始朝向
---@field height? number 初始离地高度
---@field duration? number 存活时间

---@param args? projectile.options 投射物配�?---@param ... projectile.options
---@return projectile
M.create = function(args, ...)
    args = table.merge(args, ...)
    args = args or {}
    args.name = args.name or M.settings.DEFAULT_NAME
    args.effect = args.effect or M.settings.DEFAULT_EFFECT
    args.owner = args.owner
    args.position = args.position or M.settings.DEFAULT_POSITION
    args.facing = args.facing or M.settings.DEFAULT_FACING
    args.height = args.height or M.settings.DEFAULT_HEIGHT
    args.scale = args.scale or M.settings.DEFAULT_SCALE
    args.duration = args.duration or M.settings.DEFAULT_DURATION
    assert(args.effect ~= nil, "projectile.create requires effect")

    ---@class projectile: lib.reactive.factory
    local o = factory(args)
    o.factory.set_class("projectile")

    o.factory.ref_field("effect", args.effect)
    o.factory.field("owner").ref(args.owner)
    local create_api = apis.CREATE_EFFECT({
        effect = args.effect,
        position = args.position,
        facing = args.facing,
        scale = args.scale,
        height = args.height,
        duration = args.duration,
    })
    assert(create_api.handle ~= nil, "framework.projectile.create requires runtime backend")
    o.factory.ref_field("effect_handle", create_api.handle)
    o.destroy = function()
        o.factory.delete()
    end

    M.HANDLE_TO_OBJECT[o.effect_handle()] = o

    o.factory.delete.add(function()
        apis.ON_DESTROY({ projectile = o })
    end)

    o.factory.delete.add(function()
        M.HANDLE_TO_OBJECT[o.effect_handle()] = nil
    end)

    o.factory.delete.add(function()
        apis.REMOVE({ handle = o.effect_handle() })
    end)

    require ".behaviors"(o, args)

    apis.ON_CREATE({ projectile = o })

    return o
end

return M
