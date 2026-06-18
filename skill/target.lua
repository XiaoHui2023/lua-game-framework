---@class framework.skill
local M = require ".base"
local factory_model = require "lib.reactive".factory

---@class skill.target.options: factory.options

---@param args skill.target.options
---@return skill.target
M.create_target = function (args)
    ---@class skill.target: factory
    local o = factory_model(args)
    o.set_class("skill.target")

    ---@type hook.computed 上下文<skill.context>
    o.context = o.factory.computed()

    ---@type hook.computed 组<list>
    o.group = o.factory.computed(function ()
        error("not implemented")
    end)

    return o
end