-- Forward player mouse control settings through the runtime backend APIs.
---@class framework.player
local player_model = require "framework.player"
---@type framework.player.apis
local player_apis = require "..apis"

---@param handle player.handle
---@param enable boolean
function player_model.set_mouse_click_selection(handle, enable)
    player_apis.SET_MOUSE_CLICK_SELECTION({
        handle = handle,
        enable = enable,
    })
end

---@param handle player.handle
---@param enable boolean
function player_model.set_mouse_drag_selection(handle, enable)
    player_apis.SET_MOUSE_DRAG_SELECTION({
        handle = handle,
        enable = enable,
    })
end

---@param handle player.handle
---@param enable boolean
function player_model.set_mouse_wheel(handle, enable)
    player_apis.SET_MOUSE_WHEEL({
        handle = handle,
        enable = enable,
    })
end
