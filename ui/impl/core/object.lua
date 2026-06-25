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
---@return framework.ui ui 新建的 UI 响应式对象空壳
local function create_ui_shell(args)
    local parent = args.parent
    args.parent = nil

    ---@type framework.ui
    local ui = factory(args)
    args.parent = parent
    ui.factory.set_class("ui")
    return ui
end

-- 注册 UI 创建流水线：先创建对象空壳，再按“字段 -> 逻辑”的顺序完成装配。
apis.CREATE_OBJECT(function(api)
    local args = api.options or {}
    apply_default_options(args)

    local ui = create_ui_shell(args)

    -- 字段阶段必须先运行，后续逻辑阶段会直接读取这些响应式字段。
    apis.SETUP_REACTIVE_FIELDS:emit({
        ui = ui,
        options = args,
    })
    -- 逻辑阶段只绑定监听、生命周期和运行时同步，不再创建基础字段。
    apis.SETUP_REACTIVE_LOGIC:emit({
        ui = ui,
        options = args,
    })
    api.ui = ui
end)

return true
