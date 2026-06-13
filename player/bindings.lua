---@class models.player
local g = require ".base"
---@type colorlib
local color = require "color"

---@alias player.handle Player

---得到本地玩家
---@return Player 本地玩家
local function get_local_handle()
    local rt
    y3.player.with_local(function (local_player)
        rt = local_player
    end)
    return rt
end

g.set_mouse_click_selection = function(handle,enable)
    handle:set_mouse_click_selection(enable)
end

g.set_mouse_drag_selection = function(handle,enable)
    handle:set_mouse_drag_selection(enable)
end

g.set_mouse_wheel = function (handle,enable)
    handle:set_mouse_wheel(enable)
end

g.LOCAL_HANDLE = get_local_handle()

g.LOCAL_ID = g.LOCAL_HANDLE.id

g.get_name = function (handle)
    return handle:get_name()
end

g.get_state = function(handle)
    local rt = handle:get_state()
    if rt == 1 or rt == 3 then
        return g.STATE.PLAYING
    end
    if rt == 4 then
        return g.STATE.LEFT
    end
    return g.STATE.NIL
end

g.get_controller = function(handle)
    local rt = handle:get_controller()
    if rt == 0 then
        return g.CONTROLLER.NIL
    end
    if rt == 1 then
        return g.CONTROLLER.HUMAN
    end

    return g.CONTROLLER.AI
end

g.MAX_PLAYERS = 16

g.get_color = function (id)
    local map = {
        [1] = color.RED,
        [2] = color.BLUE,
        [3] = color.CYAN,
        [4] = color.PURPLE,
        [5] = color.YELLOW,
        [6] = color.ORANGE,
        [7] = color.GREEN,
        [8] = color.PINK,
        [9] = color.GRAY,
        [10] = color.LIGHT_BLUE,
        [11] = color.DARK_GREEN,
        [12] = color.BROWN,
    }
    return map[id] or color.WHITE
end

g.set_mouse_click_selection(g.LOCAL_HANDLE, g.MOUSE_CLICK_SELECTION_ENABLE)
g.set_mouse_drag_selection(g.LOCAL_HANDLE, g.MOUSE_DRAG_SELECTION_ENABLE)
g.set_mouse_wheel(g.LOCAL_HANDLE, g.MOUSE_WHEEL_ENABLE)

return g
