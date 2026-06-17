---@class framework.skill.apis
---@field ON_CREATE_ACTION lib.callback.api 技能动作创建完成时触发
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class skill.ActionCreated
---@field action skill.action 已创建的技能动作对象
---@field options skill.action.options 创建技能动作时使用的参数
M.ON_CREATE_ACTION = callback.api({ name = "skill.ON_CREATE_ACTION" })

return M
