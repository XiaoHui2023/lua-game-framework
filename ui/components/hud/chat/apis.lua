---@class framework.ui.components.hud.chat.apis
---@field SETUP_REACTIVE_FIELDS lib.callback.api 为聊天文本对象创建响应式字段
---@field SETUP_REACTIVE_LOGIC lib.callback.api 为聊天文本对象绑定更新和淡出逻辑
---@field DISPLAY_NAME lib.callback.api 解析单条消息的显示名，外部 handler 可改写 `name`
---@field MESSAGE_COLOR lib.callback.api 解析单条消息的名字颜色，外部 handler 可改写 `color`
---@field WRAP_CONTENT lib.callback.api 按显示宽度拆分正文，外部 handler 可改写 `lines`
---@field MESSAGE_TO_LINES lib.callback.api 把单条消息转换为渲染行，外部 handler 可改写 `lines`
---@field RENDER_MESSAGES lib.callback.api 把消息列表转换为最终文本，外部 handler 可改写 `text`、`blocks` 或 `line_count`
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class framework.ui.components.hud.chat.api.SetupReactiveFields
---@field chat framework.ui.hud.chat 待装配字段的聊天文本对象
---@field limit number 最近消息条数上限

---@class framework.ui.components.hud.chat.api.SetupReactiveLogic
---@field chat framework.ui.hud.chat 待绑定逻辑的聊天文本对象
---@field args framework.ui.hud.chat.options 创建聊天组件时传入并补齐默认值后的选项

---@class framework.ui.components.hud.chat.api.DisplayName
---@field message table 原始聊天消息
---@field name string? 输出的显示名

---@class framework.ui.components.hud.chat.api.MessageColor
---@field message table 原始聊天消息
---@field color lib.color|table? 输出的玩家名颜色

---@class framework.ui.components.hud.chat.api.WrapContent
---@field content string 原始正文
---@field first_line_width integer 第一行正文宽度
---@field max_width integer 后续行正文宽度
---@field lines string[]? 输出的正文行

---@class framework.ui.components.hud.chat.api.MessageToLines
---@field message table 原始聊天消息
---@field args framework.ui.hud.chat.options 创建聊天组件时传入并补齐默认值后的选项
---@field lines string[]? 输出的整条消息渲染行

---@class framework.ui.components.hud.chat.api.RenderMessages
---@field messages table 聊天消息集合，需提供 `count` 和 `for_each`
---@field args framework.ui.hud.chat.options 创建聊天组件时传入并补齐默认值后的选项
---@field limit number 最近消息条数上限
---@field blocks string[][]? 输出的消息分块行
---@field line_count integer? 输出文本实际渲染行数
---@field text string? 输出到文本控件的最终富文本

M.SETUP_REACTIVE_FIELDS = callback.api({
    name = "framework.ui.components.hud.chat.SetupReactiveFields",
})

M.SETUP_REACTIVE_LOGIC = callback.api({
    name = "framework.ui.components.hud.chat.SetupReactiveLogic",
})

M.DISPLAY_NAME = callback.api({
    name = "framework.ui.components.hud.chat.DisplayName",
})

M.MESSAGE_COLOR = callback.api({
    name = "framework.ui.components.hud.chat.MessageColor",
})

M.WRAP_CONTENT = callback.api({
    name = "framework.ui.components.hud.chat.WrapContent",
})

M.MESSAGE_TO_LINES = callback.api({
    name = "framework.ui.components.hud.chat.MessageToLines",
})

M.RENDER_MESSAGES = callback.api({
    name = "framework.ui.components.hud.chat.RenderMessages",
})

return M
