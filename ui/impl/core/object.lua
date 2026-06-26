local factory = require("lib.reactive").factory
---@type framework.ui.layers
local layers = require "framework.ui.layers"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param args framework.ui.object_config
local function apply_default_options(args)
    args.image = args.image or ""
    args.alpha = args.alpha or 255
    args.layer = args.layer or layers.get("DEFAULT")
    args.priority = args.priority or 0
    args.progress = args.progress or 1
    args.rotation = args.rotation or 0
end

---@param args framework.ui.object_config
---@return framework.ui ui Newly created reactive UI shell.
local function create_ui_shell(args)
    local parent = args.parent
    args.parent = nil

    ---@type framework.ui
    local ui = factory(args)
    args.parent = parent
    ui.factory.set_class("ui")
    return ui
end

-- Register the UI creation pipeline: shell, fields, then logic.
apis.CREATE_OBJECT(function(api)
    local args = api.options or {}
    apply_default_options(args)

    local ui = create_ui_shell(args)

    -- Field setup must run before logic setup.
    apis.SETUP_REACTIVE_FIELDS:emit({
        ui = ui,
        options = args,
    })
    -- Logic setup binds listeners, lifecycle, and runtime sync.
    apis.SETUP_REACTIVE_LOGIC:emit({
        ui = ui,
        options = args,
    })
    api.ui = ui
end)

return true
