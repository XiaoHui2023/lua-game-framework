---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_VOID(function(api)
    local args = table.merge(api.options or {}, api.options_extra)
    args.type = args.type or "void"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_VOID requires CREATE_OBJECT result")
    local ui = create_api.ui

    ---@type reactive.event<framework.ui>
    ui.factory.on_children_layout_change.event()

    api.ui = ui
end)

return true
