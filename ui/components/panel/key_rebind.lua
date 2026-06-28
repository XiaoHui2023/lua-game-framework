---@class framework.ui.components.panel.key_rebind
local M = {}
---@type lib.metatablex
local metatable = require "lib.metatablex"

require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"
---@type lib.reactive
local reactive = require "lib.reactive"
---@type lib.colorlib
local color = require "lib.color"

M.DEFAULT_ACTIVE_COLOR = color.LIGHT_BLUE
M.DEFAULT_INACTIVE_COLOR = color.WHITE
M.DEFAULT_FOCUS_COLOR = color.BLACK
M.DEFAULT_KEY_WIDTH = 48
M.DEFAULT_KEY_HEIGHT = 32
M.DEFAULT_GAP = 6

local KEY_ROWS = {
    { "esc", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" },
    { "~", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "backspace" },
    { "tab", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\" },
    { "capslock", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "enter" },
    { "shift", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "shift" },
    { "ctrl", "win", "alt", "space", "alt", "win", "ctrl" },
}

local function create_anchor(options)
    local api = ui_apis.CREATE_ANCHOR({
        anchor = options,
    })
    assert(api.anchor ~= nil, "framework.ui.components.panel.key_rebind requires CREATE_ANCHOR result")
    return api.anchor
end

local function create_void(options)
    local api = ui_apis.CREATE_VOID({
        options = options,
    })
    assert(api.ui ~= nil, "framework.ui.components.panel.key_rebind requires CREATE_VOID result")
    return api.ui
end

local function create_text(options)
    local api = ui_apis.CREATE_TEXT({
        options = options,
    })
    assert(api.ui ~= nil, "framework.ui.components.panel.key_rebind requires CREATE_TEXT result")
    return api.ui
end

---@class framework.ui.components.panel.key_rebind.options: framework.ui.object_config
---@field name? string
---@field width? number
---@field height? number
---@field key_width? number
---@field key_height? number
---@field gap? number
---@field font_size? number

---@class framework.ui.key_rebind.root: framework.ui.void
---@field active_key lib.reactive.ref<string?>
---@field keys lib.reactive.ref<table>

---@class framework.ui.key_rebind.key: framework.ui.text
---@field key_name string
---@param args? framework.ui.components.panel.key_rebind.options
---@return framework.ui.key_rebind.root
function M.create(args)
    args = args or {}
    args.name = args.name or "key_rebind"
    args.size = args.size or { width = 760, height = 260 }

    local root = create_void(args)
    ---@type framework.ui.key_rebind.root
    root = root
    root.active_key = reactive.ref({ value = nil, name = "key_rebind.active_key" })
    root.keys = reactive.table_ref({ name = "key_rebind.keys" })

    local key_width = args.key_width or M.DEFAULT_KEY_WIDTH
    local key_height = args.key_height or M.DEFAULT_KEY_HEIGHT
    local gap = args.gap or M.DEFAULT_GAP

    for row_index, row in ipairs(KEY_ROWS) do
        for column_index, key_name in ipairs(row) do
            local key = create_text({
                name = "key_" .. row_index .. "_" .. column_index,
                parent = root.factory,
                text = key_name,
                size = { width = key_width, height = key_height },
                font_size = args.font_size or 0.1,
                focusable = true,
                clickable = true,
                anchor = create_anchor({
                    relative_ui = root,
                    point = "left_top",
                    relative_point = "left_top",
                    x = (column_index - 1) * (key_width + gap) / args.size.width,
                    y = -(row_index - 1) * (key_height + gap) / args.size.height,
                }),
            })
            ---@type framework.ui.key_rebind.key
            key = key
            key.key_name = key_name
            key.on_click.add(function()
                root.active_key.set(key_name)
            end)
            root.keys.set(row_index .. ":" .. column_index, key)
        end
    end

    return root
end

M.keyRebind = M.create
metatable.callable(M, M.create)

return M