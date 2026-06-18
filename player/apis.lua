---@class framework.player.apis
---@field PLAYER_CREATED lib.callback.api 玩家对象创建完成时触发，供框架内实现为玩家挂载通用能力
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class framework.player.api.PlayerCreated: lib.callback.instance
---@field player player 已创建完成的玩家对象
---@type lib.callback.api
M.PLAYER_CREATED = callback.api({ name = "player.PLAYER_CREATED" })

M.SET_MOUSE_CLICK_SELECTION = callback.api({ name = "player.SET_MOUSE_CLICK_SELECTION" })
M.SET_MOUSE_DRAG_SELECTION = callback.api({ name = "player.SET_MOUSE_DRAG_SELECTION" })
M.SET_MOUSE_WHEEL = callback.api({ name = "player.SET_MOUSE_WHEEL" })
M.GET_NAME = callback.api({ name = "player.GET_NAME" })
M.GET_STATE = callback.api({ name = "player.GET_STATE" })
M.GET_CONTROLLER = callback.api({ name = "player.GET_CONTROLLER" })
M.GET_COLOR = callback.api({ name = "player.GET_COLOR" })

return M
