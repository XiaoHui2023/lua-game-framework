---@class framework.ui.apis
---@field ON_MOUSE_MOVE_ASYNC lib.callback.api 本地异步鼠标移动时触发，坐标已转换为窗口比例
---@field ON_WINDOW_SIZE_CHANGE lib.callback.api 窗口尺寸变化时触发
---@field ON_CREATE lib.callback.api UI 对象创建完成时触发
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class ui.MouseMoveAsync
---@field position point 鼠标在窗口内的比例坐标
M.ON_MOUSE_MOVE_ASYNC = callback.api({ name = "ui.ON_MOUSE_MOVE_ASYNC" })

---@class ui.WindowSizeChange
---@field width integer 窗口宽度，单位像素
---@field height integer 窗口高度，单位像素
M.ON_WINDOW_SIZE_CHANGE = callback.api({ name = "ui.ON_WINDOW_SIZE_CHANGE" })

---@class ui.Created
---@field ui ui 已创建的 UI 对象
M.ON_CREATE = callback.api({ name = "ui.ON_CREATE" })

return M
