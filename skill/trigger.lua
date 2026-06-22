---@class framework.skill
local M = require "framework.skill"
local factory_model = require "lib.reactive".factory

---@class skill.trigger.options: lib.reactive.factory.options

---@param args skill.trigger.options
---@return skill.trigger
M.create_trigger = function (args)
    ---@class skill.trigger: lib.reactive.factory
    local o = factory_model(args)
    o.set_class("skill.trigger")

    ---@type hook.computed<skill.context> 上下文
    o.factory.context.computed()

    ---@type hook.computed 触发事件<hook.event>
    o.factory.field("event").computed(function ()
        error("not implemented")
    end)

    return o
end
