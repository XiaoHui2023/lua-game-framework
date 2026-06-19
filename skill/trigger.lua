---@class framework.skill
local M = require "framework.skill"
local factory_model = require "lib.reactive".factory

---@class skill.trigger.options: factory.options

---@param args skill.trigger.options
---@return skill.trigger
M.create_trigger = function (args)
    ---@class skill.trigger: factory
    local o = factory_model(args)
    o.set_class("skill.trigger")

    ---@type hook.computed 上下文<skill.context>
    o.context = o.factory.computed()

    ---@type hook.computed 触发事件<hook.event>
    o.event = o.factory.computed(function ()
        error("not implemented")
    end)

    return o
end