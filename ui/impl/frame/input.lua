---@type lib.stringx
local string = require "lib.stringx"
---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type jass
local jass = require "jass"

apis.CREATE_EDITBOX(function(api)
    local args = api.options or {}
    if settings.DEFAULT_EDITBOX_FRAME then
        args.label = args.label or settings.DEFAULT_EDITBOX_FRAME()
    end
    args.type = args.type or "input"
    args.width = args.width or 0.2
    args.height = args.height or 0.04
    args.length_limit = args.length_limit or 8
    args.is_int = args.is_int or false
    args.content = args.content or ""

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_EDITBOX requires CREATE_OBJECT result")
    local ui = create_api.ui

    ui.factory.is_int.set(args.is_int)
    ui.factory.on_input_change.event()
    ui.factory.content.set(args.content)
    ui.factory.length_limit.set(args.length_limit)

    ui.factory.interval(function()
        local new_content = jass.dzapi.frame_get_text(ui.handle())
        local old_content = ui.content()

        if new_content ~= old_content then
            ui.content.set(new_content)
            ui.on_input_change(new_content, old_content)
        end
    end)

    ui.on_input_change.add(function(new_content)
        if ui.is_int() then
            local s = string.tointeger(new_content)

            if s ~= new_content then
                s = "0"
            end

            ui.content.set(s)
            jass.dzapi.frame_set_text(ui.handle(), s)
        end
    end)

    jass.dzapi.frame_set_text_limit(ui.handle(), ui.length_limit())

    api.ui = ui
end)

return true
