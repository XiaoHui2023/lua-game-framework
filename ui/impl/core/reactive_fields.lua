---@type framework.ui.apis
local apis = require "framework.ui.apis"

-- 注册 UI 基础响应式字段；factory 负责创建字段并写回 UI 对象。
apis.SETUP_REACTIVE_FIELDS(function(api)
    ---@type framework.ui
    local ui = api.ui
    local options = api.options or {}

    ui.factory.set_field("parent", options.parent)

    local parent_handle = options.parent and options.parent.handle() or options.layer
    local create_api = apis.CREATE({
        type = options.type,
        parent_handle = parent_handle,
    })
    assert(create_api.handle ~= nil, "framework.ui.create requires runtime backend")
    ui.factory.set_field("handle", create_api.handle)

    ui.type = options.type
    ui.layer = options.layer

    ui.factory.set_field("priority", options.priority)
    ui.factory.set_field("alpha", options.alpha)
    ui.factory.set_field("image", options.image)
    ui.factory.set_field("progress", options.progress)
    ui.factory.set_field("rotation", options.rotation)
    ui.factory.set_field("color", options.color)
    ui.factory.add_field("children", {
        prevent_duplicate = true,
    })
end)

return true
