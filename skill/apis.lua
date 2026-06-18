---@class framework.skill.apis
---@field ON_CREATE_ACTION lib.callback.api 技能动作创建完成时触发，用于给动作补目标、统计值或运行逻辑
---@field REQUEST_CAST lib.callback.api 请求释放主动技能时触发，运行时可在这里接入引擎选目标、指示器、拖拽轨迹等输入
---@field BEFORE_CAST lib.callback.api 主动技能真正释放前触发，处理器可把 cancelled 置为 true 阻止释放
---@field AFTER_CAST lib.callback.api 主动技能释放完成后触发，用于接入表现、日志、同步或引擎技能实例
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class skill.ActionCreated: lib.callback.instance
---@field action skill.action 已创建的技能动作对象
---@field options skill.action.options 创建技能动作时使用的参数
M.ON_CREATE_ACTION = callback.api({ name = "skill.ON_CREATE_ACTION" })

---@class skill.api.RequestCast: lib.callback.instance
---@field skill skill.active 发起释放的主动技能
---@field request skill.cast_request 本次释放携带的输入请求
M.REQUEST_CAST = callback.api({ name = "skill.REQUEST_CAST" })

---@class skill.api.BeforeCast: lib.callback.instance
---@field skill skill.active 即将释放的主动技能
---@field request skill.cast_request 本次释放携带的输入请求
---@field cancelled boolean 是否取消本次释放，处理器可修改
---@field reason? string 字段说明
M.BEFORE_CAST = callback.api({ name = "skill.BEFORE_CAST" })

---@class skill.api.AfterCast: lib.callback.instance
---@field skill skill.active 已释放的主动技能
---@field request skill.cast_request 本次释放携带的输入请求
---@field result any 可选，技能释放逻辑返回值
M.AFTER_CAST = callback.api({ name = "skill.AFTER_CAST" })

return M
