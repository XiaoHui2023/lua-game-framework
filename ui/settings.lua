---@class framework.ui.settings
---@field DEFAULT_IMAGE any 默认图片资源
---@field DEFAULT_TEXT_FONT any 默认文本字体资源
---@field DEFAULT_TEXT_FONT_SIZE number 默认文本字号比例
---@field DEFAULT_TEXT_ALIGN framework.ui.position 默认文本对齐位置
---@field UI_APPLICATION_SIZE_SCALE number UI 尺寸写入运行时前的全局缩放比例
---@field TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE number 文本宽度测量换算比例
---@field TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE number 文本高度测量换算比例
---@field DEFAULT_EDITBOX_FRAME fun(): framework.ui|nil 默认输入框外观工厂
---@field DEFAULT_SLIDER_X_FRAME fun(): framework.ui|nil 默认横向滑条外观工厂
---@field DEFAULT_SLIDER_Y_FRAME fun(): framework.ui|nil 默认纵向滑条外观工厂
---@field DEFAULT_SLOT_IMAGE_IMAGE any 默认槽位图标图片
---@field DEFAULT_SLOT_PROGRESS_IMAGE any 默认槽位进度图片
---@field DEFAULT_SLOT_BACKGROUND_IMAGE any 默认槽位背景图片
---@field DEFAULT_COOLDOWN_READY_IMAGE any 默认冷却完成图片
---@field DEFAULT_COOLDOWN_PROGRESS_IMAGE any 默认冷却进度图片
---@field DEFAULT_TIP_FONT_SIZE number 默认提示文本字号
---@field DEFAULT_TIP_BACKGROUND_IMAGE any 默认提示背景图片
---@field DEFAULT_TIP_BORDER_IMAGE any 默认提示边框图片
local M = {}

M.DEFAULT_IMAGE = nil
M.DEFAULT_TEXT_FONT = nil
M.DEFAULT_TEXT_FONT_SIZE = 0.14
M.DEFAULT_TEXT_ALIGN = "center"
M.UI_APPLICATION_SIZE_SCALE = 1
M.TEXT_GET_TEXT_PIXEL_SIZE_WIDTH_SCALE = 1.8
M.TEXT_GET_TEXT_PIXEL_SIZE_HEIGHT_SCALE = 3.4
M.DEFAULT_EDITBOX_FRAME = nil
M.DEFAULT_SLIDER_X_FRAME = nil
M.DEFAULT_SLIDER_Y_FRAME = nil
M.DEFAULT_SLOT_IMAGE_IMAGE = nil
M.DEFAULT_SLOT_PROGRESS_IMAGE = nil
M.DEFAULT_SLOT_BACKGROUND_IMAGE = nil
M.DEFAULT_COOLDOWN_READY_IMAGE = nil
M.DEFAULT_COOLDOWN_PROGRESS_IMAGE = nil
M.DEFAULT_TIP_FONT_SIZE = 10
M.DEFAULT_TIP_BACKGROUND_IMAGE = nil
M.DEFAULT_TIP_BORDER_IMAGE = nil

return M
