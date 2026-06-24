---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.settings
local settings = require "..settings"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_PROGRESS(function(api)
    local args = table.merge(api.options or {}, api.options_extra)
    args.image = args.image or settings.DEFAULT_IMAGE
    args.type = args.type or "progress_ring"

    local create_api = apis.CREATE_OBJECT({ options = args })
    assert(create_api.ui ~= nil, "framework.ui.CREATE_PROGRESS requires CREATE_OBJECT result")
    api.ui = create_api.ui
end)

apis.CREATE_PROGRESS_RING(function(api)
    local args = api.options or {}
    args.type = "progress_ring"
    local create_api = apis.CREATE_PROGRESS({ options = args })
    api.ui = create_api.ui
end)

apis.CREATE_PROGRESS_BAR(function(api)
    local args = api.options or {}
    args.type = "progress_bar"
    local create_api = apis.CREATE_PROGRESS({ options = args })
    api.ui = create_api.ui
end)

return true
