---@type framework.ui
local ui_model = require "framework.ui"
---@type framework.ui.components.tooltip.api
local apis = require "framework.ui.components.tooltip.apis"

apis.SETUP_REACTIVE_FIELDS(function(api)
    ---@type framework.ui.components.tooltip
    local tooltip = api.tooltip

    tooltip.factory.ref_field("holder_ui", api.holder_ui)
    tooltip.factory.ref_field("text_ui", api.text_ui)
    tooltip.factory.ref_field("focus_ui", nil)
    tooltip.factory.ref_field("vertical_space", api.vertical_space)
    tooltip.factory.ref_field("horizontal_space", api.horizontal_space)
    tooltip.factory.event_field("on_focus")
    tooltip.factory.event_field("on_blur")
end)

apis.SETUP_REACTIVE_LOGIC(function(api)
    ---@type framework.ui.components.tooltip
    local tooltip = api.tooltip

    ui_model.event_registry.add("focus", function(ui)
        local description = ""
        if type(ui.description) == "function" then
            description = ui.description()
        elseif type(ui.description) == "string" then
            description = ui.description
        end
        if description == "" then
            return
        end

        tooltip.on_focus(ui)

        local holder_ui = tooltip.holder_ui()
        local text_ui = tooltip.text_ui()

        tooltip.focus_ui.set(ui)
        text_ui.text.set(description)
        api.anchor(holder_ui, ui, tooltip.vertical_space(), tooltip.horizontal_space())
        holder_ui.show.set(true)
    end)

    ui_model.event_registry.add("blur", function(ui)
        local focus_ui = tooltip.focus_ui()
        if focus_ui ~= ui then
            return
        end

        tooltip.on_blur(ui)

        local holder_ui = tooltip.holder_ui()

        tooltip.focus_ui.set(nil)
        holder_ui.show.set(false)
    end)
end)

return true
