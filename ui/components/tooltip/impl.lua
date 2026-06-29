---@type framework.ui
local ui_model = require "framework.ui"
---@type framework.ui.components.tooltip.api
local apis = require "framework.ui.components.tooltip.apis"
---@type lib.template
local template = require "lib.template"

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
    local current_unsubscribe = nil
    local current_renderer = nil

    local function clear_renderer()
        if current_unsubscribe ~= nil then
            current_unsubscribe()
            current_unsubscribe = nil
        end
        if current_renderer ~= nil then
            current_renderer.dispose()
            current_renderer = nil
        end
    end

    local function description_text(ui)
        if type(ui.description_template) == "string" then
            return template.render_text(ui.description_template, ui.description_data)
        end
        if type(ui.description) == "function" then
            return ui.description()
        end
        if type(ui.description) == "string" then
            return ui.description
        end
        return ""
    end

    local function bind_template(ui, text_ui)
        clear_renderer()
        if type(ui.description_template) ~= "string" then
            return
        end

        local renderer = ui.factory.create_computed(function()
            return template.render_text(ui.description_template, ui.description_data)
        end)
        current_renderer = renderer
        renderer.auto_update()
        text_ui.text.set(renderer())
        current_unsubscribe = renderer.on_update.add(function(content)
            if tooltip.focus_ui() == ui then
                text_ui.text.set(content)
            end
        end)
    end

    ui_model.event_registry.add("focus", function(ui)
        local description = description_text(ui)
        if description == "" then
            return
        end

        tooltip.on_focus(ui)

        local holder_ui = tooltip.holder_ui()
        local text_ui = tooltip.text_ui()

        tooltip.focus_ui.set(ui)
        text_ui.text.set(description)
        bind_template(ui, text_ui)
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

        clear_renderer()
        tooltip.focus_ui.set(nil)
        holder_ui.show.set(false)
    end)
end)

return true
