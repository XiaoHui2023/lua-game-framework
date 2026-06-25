---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_BUTTON(function(api)
    local args = api.options or {}
    args.type = args.type or "button"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_BUTTON requires CREATE_OBJECT result")
    api.ui = create_api.ui
end)

return true
