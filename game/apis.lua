---@class framework.game.apis
---@field ON_ALERT lib.callback.api 请求向玩家展示系统提示时触发
---@field END_GAME lib.callback.api 请求结束本地玩家游戏
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class game.Alert: lib.callback.instance
---@field content string 系统提示文本
---@type lib.callback.api
M.ON_ALERT = callback.api({ name = "game.ON_ALERT" })

---@class game.api.EndGame: lib.callback.instance
---@type lib.callback.api
M.END_GAME = callback.api({ name = "game.END_GAME" })

return M
