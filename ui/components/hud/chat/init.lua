---@class framework.ui.components.hud.chat
---@field apis framework.ui.components.hud.chat.apis 聊天 HUD 组件回调 API 集合
local M = {}
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"
---@type framework.ui.components.hud.chat.apis
local chat_apis = require "framework.ui.components.hud.chat.apis"

require "framework.ui.components.hud.chat.impl"

M.apis = chat_apis

M.DEFAULT_FONT_SIZE = 0.24
M.DEFAULT_ALIGN = "left_center"
M.DEFAULT_TIME_STAY = 12
M.DEFAULT_TIME_OUT = 3
M.DEFAULT_SIZE = { width = 520, height = 320 }
M.DEFAULT_ANCHOR = nil
M.DEFAULT_FONT = nil
M.DEFAULT_LIMIT = 15
M.DEFAULT_NAME_SEPARATOR = ": "
M.DEFAULT_NAME_COLUMN_WIDTH = 12
M.DEFAULT_CONTENT_LINE_WIDTH = 40
M.DEFAULT_FIRST_LINE_EXTRA_WIDTH = 0
M.DEFAULT_MAX_RENDER_LINES = 15
M.DEFAULT_INDENT_UNIT = " "

---@class framework.ui.hud.chat : framework.ui.text
---@field fade framework.ui.animation.fade 聊天栏淡出动画控制器
---@field on_update reactive.event 聊天消息更新事件
---@field limit lib.reactive.ref<number> 参与渲染的最近消息条数上限

---@class framework.ui.hud.chat.options: framework.ui.text.options
---@field name? string 控件名称，省略时使用默认聊天栏名称
---@field size? framework.ui.size_spec 控件尺寸，省略时使用默认聊天栏尺寸
---@field align? framework.ui.position 文本对齐方式，省略时使用默认左中对齐
---@field anchor? framework.ui.anchor 控件锚点，省略时不设置锚点
---@field font_size? number 字号比例，省略时使用默认聊天字号
---@field font? any 字体资源，省略时使用默认字体
---@field show? boolean 是否初始显示，省略时隐藏
---@field time_stay? number 消息停留时间，淡出前保持完全可见
---@field time_out? number 消息淡出耗时
---@field limit? number 参与渲染的最近消息条数上限
---@field name_separator? string 玩家名和正文之间的分隔文本
---@field name_column_width? integer 玩家名列显示宽度，用于计算正文对齐
---@field content_line_width? integer 正文自动换行宽度
---@field first_line_extra_width? integer 第一行额外占用宽度，越大则第一行正文越短
---@field max_render_lines? integer 最终渲染到文本控件的最大行数
---@field indent_unit? string 缩进填充单元，宽字符缩进会重复该字符串

---@param args? framework.ui.hud.chat.options
---@return framework.ui.hud.chat
M.create = function(args)
    args = args or {}
    args.size = args.size or M.DEFAULT_SIZE
    args.time_stay = args.time_stay or M.DEFAULT_TIME_STAY
    args.time_out = args.time_out or M.DEFAULT_TIME_OUT
    args.align = args.align or M.DEFAULT_ALIGN
    args.font_size = args.font_size or M.DEFAULT_FONT_SIZE
    args.anchor = args.anchor or M.DEFAULT_ANCHOR
    args.font = args.font or M.DEFAULT_FONT
    args.limit = args.limit or M.DEFAULT_LIMIT
    args.name_separator = args.name_separator or M.DEFAULT_NAME_SEPARATOR
    args.name_column_width = args.name_column_width or M.DEFAULT_NAME_COLUMN_WIDTH
    args.content_line_width = args.content_line_width or M.DEFAULT_CONTENT_LINE_WIDTH
    args.first_line_extra_width = args.first_line_extra_width or M.DEFAULT_FIRST_LINE_EXTRA_WIDTH
    args.max_render_lines = args.max_render_lines or M.DEFAULT_MAX_RENDER_LINES
    args.indent_unit = args.indent_unit or M.DEFAULT_INDENT_UNIT
    args.show = args.show or false
    args.name = args.name or "chat_bar"

    local text_api = ui_apis.CREATE_TEXT({ options = args })
    ---@type framework.ui.hud.chat
    local o = text_api.ui

    chat_apis.SETUP_REACTIVE_FIELDS({
        chat = o,
        limit = args.limit,
    })
    chat_apis.SETUP_REACTIVE_LOGIC({
        chat = o,
        args = args,
    })

    return o
end

return M
