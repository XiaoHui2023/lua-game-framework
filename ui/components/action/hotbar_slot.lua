---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"
local cooldown_animation = require "framework.ui.components.animation.cooldown"

---@class framework.ui.components.action.hotbar_slot
local M = {}

M.DEFAULT_SIZE = { width = 76, height = 96 }
M.DEFAULT_BUTTON_SIZE = { width = 72, height = 72 }
M.DEFAULT_ICON_SIZE = { width = 54, height = 54 }
M.DEFAULT_KEYCAP_SIZE = { width = 34, height = 20 }
M.DEFAULT_GAP = 4
M.DEFAULT_BACKGROUND_ALPHA = 178
M.DEFAULT_PRESSED_ALPHA = 230
M.DEFAULT_TOOLTIP_TEMPLATE = "{slot.label}\n{slot.description}\n按键：{slot.key}"

local function call_ref(ref)
    if type(ref) == "function" then
        return ref()
    end
    return ref
end

local function cooldown_progress(source)
    if source == nil or type(source.get_max_cooldown) ~= "function" then
        return 1
    end
    local max = source.get_max_cooldown()
    if max <= 0 then
        return 1
    end
    return 1 - source.cooldown() / max
end

---@param slot framework.hotbar.slot
---@param args? table
---@return framework.ui.container
function M.create(slot, args)
    args = args or {}
    args.size = args.size or M.DEFAULT_SIZE
    args.button_size = args.button_size or M.DEFAULT_BUTTON_SIZE

    local root = ui_apis.CREATE_CONTAINER({ options = {
        name = args.name or "hotbar_slot",
        size = args.size,
        layout = {
            type = "stack",
            direction = "vertical",
            gap = args.gap or M.DEFAULT_GAP,
        },
        focusable = true,
        show = true,
    } }).ui

    local button = ui_apis.CREATE_SLOT({ options = table.merge({
        name = "button",
        size = args.button_size,
        focusable = true,
        clickable = true,
        background = {
            enable = true,
            image = args.frame_image,
            alpha = M.DEFAULT_BACKGROUND_ALPHA,
            size = args.button_size,
        },
        image = {
            enable = true,
            image = call_ref(slot.icon),
            size = args.icon_size or M.DEFAULT_ICON_SIZE,
        },
    }, args.button_extra) }).ui

    local keycap = ui_apis.CREATE_SLOT({ options = table.merge({
        name = "keycap",
        size = args.keycap_size or M.DEFAULT_KEYCAP_SIZE,
        background = {
            enable = true,
            image = args.keycap_image,
            alpha = 190,
            size = args.keycap_size or M.DEFAULT_KEYCAP_SIZE,
        },
        text = {
            enable = true,
            text = slot.key() or "",
            font_size = 0.12,
            color = { red = 255, green = 244, blue = 214 },
            size = args.keycap_size or M.DEFAULT_KEYCAP_SIZE,
        },
    }, args.keycap_extra) }).ui

    root.factory.add_children({
        button.factory,
        keycap.factory,
    })

    root.button = button
    root.keycap = keycap
    root.description_template = args.description_template or M.DEFAULT_TOOLTIP_TEMPLATE
    root.description_data = { slot = slot }
    button.description_template = root.description_template
    button.description_data = root.description_data

    root.cooldown_animation = cooldown_animation.cooldown({ ui = button })

    local function refresh_key()
        if keycap.text ~= nil then
            keycap.text.text.set(slot.key() or "")
        end
    end

    local function refresh_icon()
        if button.image ~= nil then
            button.image.image.set(call_ref(slot.icon))
        end
    end

    local function refresh_cooldown()
        local source = slot.cooldown_source()
        root.cooldown_animation.progress.set(cooldown_progress(source))
    end
    local unbind_cooldown_source = nil

    local function bind_cooldown_source()
        if unbind_cooldown_source ~= nil then
            unbind_cooldown_source()
            unbind_cooldown_source = nil
        end
        local source = slot.cooldown_source()
        if source ~= nil and source.cooldown ~= nil then
            unbind_cooldown_source = source.cooldown.on_change.add(refresh_cooldown)
        end
        refresh_cooldown()
    end

    slot.key.on_change.add(refresh_key)
    slot.icon.on_change.add(refresh_icon)
    slot.cooldown_source.on_change.add(function()
        bind_cooldown_source()
    end)
    slot.on_key_down.add(function()
        button.alpha.set(M.DEFAULT_PRESSED_ALPHA)
        keycap.alpha.set(M.DEFAULT_PRESSED_ALPHA)
    end)
    slot.on_key_up.add(function()
        button.alpha.set(255)
        keycap.alpha.set(255)
    end)

    button.on_mouse_left_down.add(function()
        slot.on_key_down()
    end)
    button.on_mouse_left_up.add(function()
        slot.on_key_up()
    end)
    button.on_click.add(function()
        slot.activate({ source = "ui" })
    end)

    bind_cooldown_source()
    root.factory.delete.add(function()
        if unbind_cooldown_source ~= nil then
            unbind_cooldown_source()
            unbind_cooldown_source = nil
        end
    end)
    refresh_key()
    refresh_icon()

    return root
end

return M
