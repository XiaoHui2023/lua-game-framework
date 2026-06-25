---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.settings
local settings = require "framework.ui.settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_IMAGE(function(api)
    local args = table.merge(api.options or {}, api.options_extra)
    args.image = args.image or settings.DEFAULT_IMAGE
    args.type = args.type or "image"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_IMAGE requires CREATE_OBJECT result")
    api.ui = create_api.ui
end)

return true
