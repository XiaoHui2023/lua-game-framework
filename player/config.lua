---@class models.player
---@field MOUSE_CLICK_SELECTION_ENABLE boolean 鼠标点选使能
---@field MOUSE_DRAG_SELECTION_ENABLE boolean 鼠标框选使能
---@field MOUSE_WHEEL_ENABLE boolean 鼠标滚轮使能
local g = require ".base"

g.MOUSE_CLICK_SELECTION_ENABLE = true
g.MOUSE_DRAG_SELECTION_ENABLE = true
g.MOUSE_WHEEL_ENABLE = true

return g