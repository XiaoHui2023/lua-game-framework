---@type models.event
local M = require ".base"
---@type models.player
local Player = require "models.player"
---@type models.unit
local Unit = require "models.unit"
---@type utils.hook
local hook = require "utils.hook"

-- 开启同步
y3.config.sync.key = true
y3.config.sync.mouse = true
y3.config.sync.camera = true

---@type unit?
local hover_unit = nil
---@type any?
local hover_destructible = nil
---@type point?
local pointing_world_pos = nil

---@class event.load_input.options : event.input
---@field world_pos? point 字段说明
---@field window_pos? point 字段说明

-- 加载输入信息
---@param args? event.load_input.options 参数说明
---@return event.input
local function load_input(args)
    args = args or {}
    ---@type player.handle
    local local_player = Player.get_local().handle()
    if not args.world_pos then
        ---@type Point
        local pointing_world_pos = local_player:get_mouse_pos()
        args.world_pos = {x=pointing_world_pos:get_x(), y=pointing_world_pos:get_y()}
    end
    args.window_pos = args.window_pos or {x=local_player:get_mouse_pos_x(), y=local_player:get_mouse_pos_y()}
    args.unit = args.unit or hover_unit
    args.destructible = args.destructible or hover_destructible
    return args
end

y3.game:event('本地-鼠标-悬停', function (trg, data)
    hover_unit = nil
    hover_destructible = nil
    if data.unit then
        hover_unit = Unit.HANDLE_TO_OBJECT[data.unit]
    end
    if data.destructible then
        --hover_destructible = data.destructible
    end
end)

y3.game:event('玩家-离开游戏', function (trg, data)
    M.ON_PLAYER_LEAVE(data.player)
end)

y3.game:event('游戏-初始化', function (trg, data)
    M.ON_GAME_INIT()
end)

y3.game:event('单位-受到伤害时', function (trg, data)
    M.ON_UNIT_DAMAGE_TAKEN(data.unit, data.source_unit)
end)

y3.game:event('单位-造成伤害时', function (trg, data)
    M.ON_UNTI_DAMAGE_DEALT(data.unit, data.target_unit)
end)

--y3.game:event('单位-施放技能', function (trg, data)
--end)

y3.game:event('本地-鼠标-移动', function (trg, data)
    M.ON_MOUSE_MOVE_ASYNC(load_input({
        world_pos={x=data.pointing_world_pos:get_x(), y=data.pointing_world_pos:get_y()},
        window_pos={x=data.tar_x, y=data.tar_y},
    }))
end)

y3.game:event('本地-鼠标-滚轮', 'WHEEL_UP',function (trg, data)
    M.ON_WHEEL_UP()
end)

y3.game:event('本地-鼠标-滚轮', 'WHEEL_DOWN',function (trg, data)
    M.ON_WHEEL_DOWN()
end)

---@type table<y3.Const.MouseKey,event.mouse>
local to_mouse = {
    [y3.const.MouseKey.LEFT] = 'LEFT',
    [y3.const.MouseKey.RIGHT] = 'RIGHT',
    [y3.const.MouseKey.MIDDLE] = 'MIDDLE',
    [y3.const.MouseKey.WHEEL_UP] = 'WHEEL_UP',
    [y3.const.MouseKey.WHEEL_DOWN] = 'WHEEL_DOWN',
}

for y3_mouse, event_mouse in table.sorted_pairs(to_mouse) do
    y3.game:event('本地-鼠标-按下', y3_mouse, function (trg, data)
        M.ON_MOUSE_DOWN_ASYNC(load_input({
            world_pos={x=data.pointing_world_pos.x, y=data.pointing_world_pos.y},
            mouse=event_mouse,
        }))
    end)
    y3.game:event('本地-鼠标-抬起', y3_mouse, function (trg, data)
        M.ON_MOUSE_UP_ASYNC(load_input({
            world_pos={x=data.pointing_world_pos.x, y=data.pointing_world_pos.y},
            mouse=event_mouse,
        }))
    end)
end

---@type table<y3.Const.KeyboardKey,event.key>
local to_key = {
    [y3.const.KeyboardKey.SPACE] = 'SPACE',
    [y3.const.KeyboardKey.ENTER] = 'ENTER',
    [y3.const.KeyboardKey.ESCAPE] = 'ESCAPE',
    [y3.const.KeyboardKey.TAB] = 'TAB',
    [y3.const.KeyboardKey.BACKSPACE] = 'BACKSPACE',
    [y3.const.KeyboardKey.RSHIFT] = 'SHIFT',
    [y3.const.KeyboardKey.RCTRL] = 'CONTROL',
    [y3.const.KeyboardKey.R_ALT] = 'ALT',
    [y3.const.KeyboardKey.LSHIFT] = 'SHIFT',
    [y3.const.KeyboardKey.LCTRL] = 'CONTROL',
    [y3.const.KeyboardKey.LALT] = 'ALT',
    [y3.const.KeyboardKey.CAPSLOCK] = 'CAPSLOCK',
    [y3.const.KeyboardKey.LEFTARROW] = 'LEFT',
    [y3.const.KeyboardKey.RIGHTARROW] = 'RIGHT',
    [y3.const.KeyboardKey.UPARROW] = 'UP',
    [y3.const.KeyboardKey.DOWNARROW] = 'DOWN',
    [y3.const.KeyboardKey.HOME] = 'HOME',
    [y3.const.KeyboardKey.END] = 'END',
    [y3.const.KeyboardKey.PAGEUP] = 'PAGEUP',
    [y3.const.KeyboardKey.PAGEDOWN] = 'PAGEDOWN',
    [y3.const.KeyboardKey.F1] = 'F1',
    [y3.const.KeyboardKey.F2] = 'F2',
    [y3.const.KeyboardKey.F3] = 'F3',
    [y3.const.KeyboardKey.F4] = 'F4',
    [y3.const.KeyboardKey.F5] = 'F5',
    [y3.const.KeyboardKey.F6] = 'F6',
    [y3.const.KeyboardKey.F7] = 'F7',
    [y3.const.KeyboardKey.F8] = 'F8',
    [y3.const.KeyboardKey.F9] = 'F9',
    [y3.const.KeyboardKey.F10] = 'F10',
    [y3.const.KeyboardKey.F11] = 'F11',
    [y3.const.KeyboardKey.F12] = 'F12',
    [y3.const.KeyboardKey.NUM_0] = 'NUM0',
    [y3.const.KeyboardKey.NUM_1] = 'NUM1',
    [y3.const.KeyboardKey.NUM_2] = 'NUM2',
    [y3.const.KeyboardKey.NUM_3] = 'NUM3',
    [y3.const.KeyboardKey.NUM_4] = 'NUM4',
    [y3.const.KeyboardKey.NUM_5] = 'NUM5',
    [y3.const.KeyboardKey.NUM_6] = 'NUM6',
    [y3.const.KeyboardKey.NUM_7] = 'NUM7',
    [y3.const.KeyboardKey.NUM_8] = 'NUM8',
    [y3.const.KeyboardKey.NUM_9] = 'NUM9',
    [y3.const.KeyboardKey.NUM_MINUS] = 'NUMMINUS',
    [y3.const.KeyboardKey.NUM_ADD] = 'NUMADD',
    [y3.const.KeyboardKey.NUM_ENTER] = 'NUMENTER',
    [y3.const.KeyboardKey.NUM_PERIOD] = 'NUMPERIOD',
    [y3.const.KeyboardKey.INSERT] = 'INSERT',
    [y3.const.KeyboardKey.DELETE] = 'DELETE',
    [y3.const.KeyboardKey.HOME] = 'HOME',
    [y3.const.KeyboardKey.END] = 'END',
    [y3.const.KeyboardKey.PAGEUP] = 'PAGEUP',
    [y3.const.KeyboardKey.PAGEDOWN] = 'PAGEDOWN',
    [y3.const.KeyboardKey.A] = 'A',
    [y3.const.KeyboardKey.B] = 'B',
    [y3.const.KeyboardKey.C] = 'C',
    [y3.const.KeyboardKey.D] = 'D',
    [y3.const.KeyboardKey.E] = 'E',
    [y3.const.KeyboardKey.F] = 'F',
    [y3.const.KeyboardKey.G] = 'G',
    [y3.const.KeyboardKey.H] = 'H',
    [y3.const.KeyboardKey.I] = 'I',
    [y3.const.KeyboardKey.J] = 'J',
    [y3.const.KeyboardKey.K] = 'K',
    [y3.const.KeyboardKey.L] = 'L',
    [y3.const.KeyboardKey.M] = 'M',
    [y3.const.KeyboardKey.N] = 'N',
    [y3.const.KeyboardKey.O] = 'O',
    [y3.const.KeyboardKey.P] = 'P',
    [y3.const.KeyboardKey.Q] = 'Q',
    [y3.const.KeyboardKey.R] = 'R',
    [y3.const.KeyboardKey.S] = 'S',
    [y3.const.KeyboardKey.T] = 'T',
    [y3.const.KeyboardKey.U] = 'U',
    [y3.const.KeyboardKey.V] = 'V',
    [y3.const.KeyboardKey.W] = 'W',
    [y3.const.KeyboardKey.X] = 'X',
    [y3.const.KeyboardKey.Y] = 'Y',
    [y3.const.KeyboardKey.Z] = 'Z',
}

for y3_key, event_key in table.sorted_pairs(to_key) do
    ---@cast event_key event.key
    y3.game:event('本地-键盘-按下', y3_key, function (trg, data)
        M.ON_KEY_DOWN_ASYNC(load_input({
            key=event_key,
        }))
    end)
    y3.game:event('本地-键盘-抬起', y3_key, function (trg, data)
        M.ON_KEY_UP_ASYNC(load_input({
            key=event_key,
        }))
    end)
end

y3.timer.loop_frame(1,function()
    M.ON_UPDATE()
    hook.ON_UPDATE()
    M.ONCE_UPDATE()
end)

y3.game:event('选中-单位', function (trg, data)
    ---@type player.handle
    local player_handle = data.player
    ---@type unit.handle
    local unit_handle = data.unit
    ---@type player
    local player = Player.get(player_handle.id)
    ---@type unit?
    local u = Unit.HANDLE_TO_OBJECT[unit_handle]
    if u == nil then
        return
    end
    M.ON_SELECT_UNIT(player, u)
end)

return M
