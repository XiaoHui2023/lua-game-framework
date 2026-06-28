-- 注册聊天 HUD 组件的默认字段、换行、颜色、行数裁剪和渲染文本组装逻辑。
---@type framework.ui.components.animation.fade
local fade_prefab = require "framework.ui.components.animation.fade"
---@type framework.ui.components.hud.chat.apis
local apis = require "framework.ui.components.hud.chat.apis"
---@type lib.colorlib
local color = require "lib.color"

local DEFAULT_INDENT_UNIT = " "

local function color_prefix(co)
    co = co or color.WHITE
    return string.format("#%02X%02X%02X", co.red or 255, co.green or 255, co.blue or 255)
end

local function utf8_char_len(byte)
    if byte < 0x80 then
        return 1
    elseif byte < 0xE0 then
        return 2
    elseif byte < 0xF0 then
        return 3
    end
    return 4
end

local function each_char(text, callback)
    local index = 1
    while index <= #text do
        local byte = text:byte(index)
        local len = utf8_char_len(byte)
        callback(text:sub(index, index + len - 1), byte)
        index = index + len
    end
end

local function char_width(byte)
    return byte < 0x80 and 1 or 2
end

local function display_width(text)
    local width = 0
    each_char(tostring(text or ""), function(_, byte)
        width = width + char_width(byte)
    end)
    return width
end

local function padding(width, indent_unit)
    if width <= 0 then
        return ""
    end
    indent_unit = indent_unit or DEFAULT_INDENT_UNIT
    local wide_count = math.floor(width / 2)
    local narrow_count = width % 2
    return string.rep(indent_unit, wide_count) .. string.rep(" ", narrow_count)
end

apis.SETUP_REACTIVE_FIELDS(function(api)
    ---@type framework.ui.hud.chat
    local chat = api.chat

    chat.factory.event_field("on_update")
    chat.factory.ref_field("limit", api.limit)
end)

apis.SETUP_REACTIVE_LOGIC(function(api)
    ---@type framework.ui.hud.chat
    local chat = api.chat
    local args = api.args

    chat.fade = fade_prefab.create({
        ui = chat,
        time_stay = args.time_stay,
        time_out = args.time_out,
    })

    chat.on_update.add(function(messages)
        local render_api = apis.RENDER_MESSAGES({
            messages = messages,
            args = args,
            limit = chat.limit(),
        })

        chat.text.set(render_api.text or "")
        chat.fade()
    end)
end)

apis.DISPLAY_NAME(function(api)
    local message = api.message or {}

    if message.sender_name then
        api.name = message.sender_name
        return
    end
    if message.player then
        api.name = message.player.factory.name()
        return
    end
    api.name = "system"
end)

apis.MESSAGE_COLOR(function(api)
    local message = api.message or {}

    if message.sender_color then
        api.color = message.sender_color
        return
    end
    if message.player then
        api.color = message.player.color()
        return
    end
    api.color = color.WHITE
end)

apis.WRAP_CONTENT(function(api)
    local content = tostring(api.content or "")
    local first_line_width = api.first_line_width
    local max_width = api.max_width
    local lines = {}
    local current = {}
    local current_width = 0
    local line_width = first_line_width

    each_char(content, function(char, byte)
        if char == "\n" then
            lines[#lines + 1] = table.concat(current)
            current = {}
            current_width = 0
            line_width = max_width
            return
        end

        local width = char_width(byte)
        if current_width > 0 and current_width + width > line_width then
            lines[#lines + 1] = table.concat(current)
            current = {}
            current_width = 0
            line_width = max_width
        end

        current[#current + 1] = char
        current_width = current_width + width
    end)

    lines[#lines + 1] = table.concat(current)
    api.lines = lines
end)

apis.MESSAGE_TO_LINES(function(api)
    local message = api.message or {}
    local args = api.args or {}
    local name_api = apis.DISPLAY_NAME({ message = message })
    local name = tostring(name_api.name or "system") .. tostring(args.name_separator or ": ")
    local content = tostring(message.content or "")
    local name_width = display_width(name)
    local name_padding = padding(math.max((args.name_column_width or 0) - name_width, 1), args.indent_unit)
    local continuation_padding = padding(args.name_column_width or 0, args.indent_unit)
    local first_line_width = math.max(8, (args.content_line_width or 0) - (args.first_line_extra_width or 0))
    local content_api = apis.WRAP_CONTENT({
        content = content,
        first_line_width = first_line_width,
        max_width = args.content_line_width or first_line_width,
    })
    local color_api = apis.MESSAGE_COLOR({ message = message })
    local lines = {}

    for index, line in ipairs(content_api.lines or {}) do
        if index == 1 then
            lines[#lines + 1] = color_prefix(color_api.color)
                .. name
                .. color_prefix(color.WHITE)
                .. name_padding
                .. line
        else
            lines[#lines + 1] = continuation_padding .. line
        end
    end

    api.lines = lines
end)

apis.RENDER_MESSAGES(function(api)
    local messages = api.messages
    local args = api.args or {}
    local blocks = {}
    local limit = api.limit or 0
    local sum = messages and messages.count or 0

    if messages ~= nil then
        messages.for_each(function(message, context)
            if context.index > sum - limit then
                local line_api = apis.MESSAGE_TO_LINES({
                    message = message,
                    args = args,
                })
                blocks[#blocks + 1] = line_api.lines or {}
            end
        end)
    end

    local strings = {}
    local line_count = 0
    for index = #blocks, 1, -1 do
        local block = blocks[index]
        if line_count > 0 and line_count + #block > (args.max_render_lines or 0) then
            break
        end
        for line_index = #block, 1, -1 do
            table.insert(strings, 1, block[line_index])
        end
        line_count = line_count + #block
    end

    api.blocks = blocks
    api.line_count = line_count
    api.text = table.concat(strings, "\n")
end)

return true
