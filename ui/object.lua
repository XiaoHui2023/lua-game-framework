local factory = require("lib.reactive").factory
---@type framework.ui
local ui_model = require "framework.ui"
---@type framework.ui.apis
local apis = require ".apis"

apis.CREATE_OBJECT(function(api)
    local args = api.options or {}
    args.image = args.image or ""
    args.alpha = args.alpha or 255
    args.layer = args.layer or ui_model.LAYER.DEFAULT
    args.priority = args.priority or 0
    args.progress = args.progress or 1
    args.rotation = args.rotation or 0

    ---@type framework.ui
    local ui = factory(args)

    ui.set_class("ui")

    apis.SETUP_REACTIVE_FIELDS:emit({
        ui = ui,
        options = args,
    })
    apis.SETUP_REACTIVE_LOGIC:emit({
        ui = ui,
        options = args,
    })

    api.ui = ui
end)

return true
