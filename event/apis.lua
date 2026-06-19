---@class framework.event.apis
---@field ON_PLAYER_LEAVE lib.callback.api 玩家离开游戏时触发
---@field ON_GAME_INIT lib.callback.api 游戏初始化时触发
---@field ON_UNIT_DAMAGE_TAKEN lib.callback.api 单位受到伤害时触发
---@field ON_UNIT_DAMAGE_DEALT lib.callback.api 单位造成伤害时触发
---@field ON_UNTI_DAMAGE_DEALT lib.callback.api ON_UNIT_DAMAGE_DEALT 的兼容别名
---@field ON_KEY_DOWN_ASYNC lib.callback.api 本地异步键盘按下时触发
---@field ON_KEY_UP_ASYNC lib.callback.api 本地异步键盘抬起时触发
---@field ON_MOUSE_MOVE_ASYNC lib.callback.api 本地异步鼠标移动时触发
---@field ON_MOUSE_DOWN_ASYNC lib.callback.api 本地异步鼠标按下时触发
---@field ON_MOUSE_UP_ASYNC lib.callback.api 本地异步鼠标抬起时触发
---@field ON_WHEEL_UP lib.callback.api 鼠标滚轮向上滚动时触发
---@field ON_WHEEL_DOWN lib.callback.api 鼠标滚轮向下滚动时触发
---@field ON_SELECT_UNIT lib.callback.api 玩家选中单位时触发
---@field ON_UPDATE lib.callback.api 每次更新时触发
---@field ONCE_UPDATE lib.callback.api 下一次更新时触发一次
---@field ON_KEY_DOWN_SYNC lib.callback.api 同步后的键盘按下事件
---@field ON_KEY_UP_SYNC lib.callback.api 同步后的键盘抬起事件
---@field ON_MOUSE_MOVE_SYNC lib.callback.api 同步后的鼠标移动事件
---@field ON_MOUSE_DOWN_SYNC lib.callback.api 同步后的鼠标按下事件
---@field ON_MOUSE_UP_SYNC lib.callback.api 同步后的鼠标抬起事件
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class event.PlayerLeave: lib.callback.instance
---@field player player.handle 离开游戏的玩家句柄
---@type lib.callback.api
M.ON_PLAYER_LEAVE = callback.api({ name = "event.ON_PLAYER_LEAVE" })

---@class event.GameInit: lib.callback.instance
---@type lib.callback.api
M.ON_GAME_INIT = callback.api({ name = "event.ON_GAME_INIT" })

---@class event.UnitDamageTaken: lib.callback.instance
---@field target_handle unit.handle 受到伤害的单位句柄
---@field source_handle unit.handle 造成伤害的来源单位句柄
---@type lib.callback.api
M.ON_UNIT_DAMAGE_TAKEN = callback.api({ name = "event.ON_UNIT_DAMAGE_TAKEN" })

---@class event.UnitDamageDealt: lib.callback.instance
---@field source_handle unit.handle 造成伤害的来源单位句柄
---@field target_handle unit.handle 受到伤害的目标单位句柄
---@type lib.callback.api
M.ON_UNIT_DAMAGE_DEALT = callback.api({ name = "event.ON_UNIT_DAMAGE_DEALT" })
M.ON_UNTI_DAMAGE_DEALT = M.ON_UNIT_DAMAGE_DEALT

---@class event.InputAsync: lib.callback.instance
---@field input event.input 本地异步输入数据
---@type lib.callback.api
M.ON_KEY_DOWN_ASYNC = callback.api({ name = "event.ON_KEY_DOWN_ASYNC" })
M.ON_KEY_UP_ASYNC = callback.api({ name = "event.ON_KEY_UP_ASYNC" })
M.ON_MOUSE_MOVE_ASYNC = callback.api({ name = "event.ON_MOUSE_MOVE_ASYNC" })
M.ON_MOUSE_DOWN_ASYNC = callback.api({ name = "event.ON_MOUSE_DOWN_ASYNC" })
M.ON_MOUSE_UP_ASYNC = callback.api({ name = "event.ON_MOUSE_UP_ASYNC" })

---@class event.Wheel: lib.callback.instance
---@field input event.input 本地异步输入数据，mouse 表示滚轮方向
---@type lib.callback.api
M.ON_WHEEL_UP = callback.api({ name = "event.ON_WHEEL_UP" })
M.ON_WHEEL_DOWN = callback.api({ name = "event.ON_WHEEL_DOWN" })

---@class event.SelectUnit: lib.callback.instance
---@field player player 执行选择的玩家
---@field unit unit 被选中的单位
---@type lib.callback.api
M.ON_SELECT_UNIT = callback.api({ name = "event.ON_SELECT_UNIT" })

---@class event.Update: lib.callback.instance
---@type lib.callback.api
M.ON_UPDATE = callback.api({ name = "event.ON_UPDATE" })
M.ONCE_UPDATE = callback.api({ name = "event.ONCE_UPDATE", mode = "once" })

---@class event.InputSync: lib.callback.instance
---@field input event.input.sync 同步后的输入数据，包含来源玩家
---@type lib.callback.api
M.ON_KEY_DOWN_SYNC = callback.api({ name = "event.ON_KEY_DOWN_SYNC" })
M.ON_KEY_UP_SYNC = callback.api({ name = "event.ON_KEY_UP_SYNC" })
M.ON_MOUSE_MOVE_SYNC = callback.api({ name = "event.ON_MOUSE_MOVE_SYNC" })
M.ON_MOUSE_DOWN_SYNC = callback.api({ name = "event.ON_MOUSE_DOWN_SYNC" })
M.ON_MOUSE_UP_SYNC = callback.api({ name = "event.ON_MOUSE_UP_SYNC" })

return M
