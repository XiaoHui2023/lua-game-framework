-- 注册动作状态树的默认逐帧推进逻辑。
---@type framework.event.apis
local event_apis = require "framework.event.apis"
---@type framework.action
local action = require "framework.action"

event_apis.ON_UPDATE(function(api)
    action.update(api.delta or api.dt or action.DEFAULT_UPDATE_DELTA)
end)

return true
