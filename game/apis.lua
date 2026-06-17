---@class framework.game.apis
---@field ON_ALERT lib.callback.api 请求向玩家展示系统提示时触发
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class game.Alert
---@field content string 系统提示文本
M.ON_ALERT = callback.api({ name = "game.ON_ALERT" })

return M
