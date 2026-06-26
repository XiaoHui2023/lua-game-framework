---@class framework.skill
local M = require "framework.skill"
local factory_model = require "lib.reactive".factory

---@class skill.target.options: lib.reactive.factory.options

---@param args skill.target.options
---@return skill.target
M.create_target = function (args)
    ---@class skill.target: lib.reactive.factory
    local o = factory_model(args)
    o.factory.set_class("skill.target")

    ---@type hook.computed<skill.context> 上下文
    o.factory.computed_field("context")

    ---@type hook.computed<list> 目标组
    o.factory.computed_field("group", function ()
        error("not implemented")
    end)

    return o
end
