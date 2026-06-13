---@class core.movement
local g = require ".base"
---@type utils.hook
local hook = require "utils.hook"

---@class core.movement.controller.options: hook.factory.options
---@field dt number 时间增量（一帧时长）

-- 控制器
---@param args core.movement.controller.options
---@return core.movement.controller
g.controller = function (args)
    ---@class core.movement.controller : hook.factory
    local o = hook.factory(args)
    o.set_class("core.movement.controller")

    ---@type hook.event 更新帧事件<core.movement.data>
    o.on_update = o.factory.event()

    ---@type hook.event 帧构建处理器事件<core.movement.handler>
    o.on_build = o.factory.event()

    ---@type hook.event 帧完成事件<core.movement.result>
    o.on_complete = o.factory.event()

    -- 构建处理器
    ---@return core.movement.handler
    local function build_handler()
        ---@type core.movement.handler 处理器
        local handler = g.handler()
        o.on_build(handler)
        return handler
    end

    -- 绑定更新帧事件
    o.on_update.add(function (data)
        local handler = build_handler()
        local result = handler.run(data)
        o.on_complete(result)
    end)

    return o
end