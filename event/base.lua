---@class models.event
local g = {}
---@type utils.hook
local hook = require "utils.hook"

---@class event.input
---@field world_pos point 世界坐标
---@field window_pos point 窗口坐标
---@field unit? unit 单位
---@field destructible? any 可破坏物
---@field key? event.key 按键
---@field mouse? event.mouse 鼠标

---@class event.input.sync: event.input
---@field player player 触发玩家


---@type hook.event 玩家离开事件（player.handle）
g.ON_PLAYER_LEAVE = hook.event()
---@type hook.event 游戏初始化事件
g.ON_GAME_INIT = hook.event()
---@type hook.event 单位受到伤害事件（受伤者:unit.handle, 攻击者:unit.handle）
g.ON_UNIT_DAMAGE_TAKEN = hook.event()
---@type hook.event 单位造成伤害事件（攻击者:unit.handle, 受伤者:unit.handle）
g.ON_UNTI_DAMAGE_DEALT = hook.event()
---@type hook.event<event.input> 按键按下异步事件
g.ON_KEY_DOWN_ASYNC = hook.event()
---@type hook.event<event.input> 按键抬起异步事件
g.ON_KEY_UP_ASYNC = hook.event()
---@type hook.event<event.input> 鼠标移动异步事件
g.ON_MOUSE_MOVE_ASYNC = hook.event()
---@type hook.event<event.input> 鼠标按下异步事件
g.ON_MOUSE_DOWN_ASYNC = hook.event()
---@type hook.event<event.input> 鼠标抬起异步事件
g.ON_MOUSE_UP_ASYNC = hook.event()
---@type hook.event 鼠标向上滚轮事件
g.ON_WHEEL_UP = hook.event()
---@type hook.event 鼠标向下滚轮事件
g.ON_WHEEL_DOWN = hook.event()
---@type hook.event 选择单位事件<player, unit>
g.ON_SELECT_UNIT = hook.event()
---@type hook.event 帧更新事件
g.ON_UPDATE = hook.event()
---@type hook.once_event 帧更新删除
g.ONCE_UPDATE = hook.once_event()
---@type hook.event<event.input.sync> 按键按下同步事件
g.ON_KEY_DOWN_SYNC = hook.event()
---@type hook.event<event.input.sync> 按键抬起同步事件
g.ON_KEY_UP_SYNC = hook.event()
---@type hook.event<event.input.sync> 鼠标移动同步事件
g.ON_MOUSE_MOVE_SYNC = hook.event()
---@type hook.event<event.input.sync> 鼠标按下同步事件
g.ON_MOUSE_DOWN_SYNC = hook.event()
---@type hook.event<event.input.sync> 鼠标抬起同步事件
g.ON_MOUSE_UP_SYNC = hook.event()

---@alias event.mouse
---| "LEFT"
---| "RIGHT"
---| "MIDDLE"
---| "WHEEL_UP"
---| "WHEEL_DOWN"

---@alias event.key
---| "A" 
---| "B" 
---| "C" 
---| "D" 
---| "E" 
---| "F" 
---| "G" 
---| "H" 
---| "I" 
---| "J" 
---| "K" 
---| "L" 
---| "M" 
---| "N" 
---| "O" 
---| "P" 
---| "Q" 
---| "R" 
---| "S" 
---| "T" 
---| "U" 
---| "V" 
---| "W" 
---| "X" 
---| "Y" 
---| "Z" 
---| "0" 
---| "1" 
---| "2" 
---| "3" 
---| "4" 
---| "5" 
---| "6" 
---| "7" 
---| "8" 
---| "9" 
---| "F1" 
---| "F2" 
---| "F3" 
---| "F4" 
---| "F5" 
---| "F6" 
---| "F7" 
---| "F8" 
---| "F9"
---| "F10"
---| "F11"
---| "F12"
---| "SPACE"
---| "ENTER"
---| "ESCAPE"
---| "TAB"
---| "BACKSPACE"
---| "SHIFT"
---| "CONTROL"
---| "ALT"
---| "CAPSLOCK"
---| "LEFT"
---| "RIGHT"
---| "UP"
---| "DOWN"
---| "HOME"
---| "END"
---| "PAGEUP"
---| "PAGEDOWN"
---| "PRINTSCREEN"
---| "SCROLLLOCK"

return g
