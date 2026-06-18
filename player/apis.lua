---@class framework.player.apis
---@field PLAYER_CREATED lib.callback.api 玩家对象创建完成时触发，供框架内实现为玩家挂载通用能力
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class framework.player.api.PlayerCreated: lib.callback.instance
---@field player player 已创建完成的玩家对象
---@type lib.callback.api
M.PLAYER_CREATED = callback.api({ name = "player.PLAYER_CREATED" })

return M
