---@type framework.ui.apis
local apis = require "framework.ui.apis"
local length = require "framework.ui.impl.core.length"

apis.GET_SCRIPT_RECT(function(api)
    local rect = api.ui.render_rect()
    api.x = rect.x
    api.y = rect.y
    api.width = rect.width
    api.height = rect.height
    api.rect = length.copy_rect(rect)
end)

apis.GET_SCRIPT_POSITION(function(api)
    local rect_api = apis.GET_SCRIPT_RECT({ ui = api.ui })
    api.x = rect_api.x
    api.y = rect_api.y
end)

apis.GET_SCRIPT_SIZE(function(api)
    local rect_api = apis.GET_SCRIPT_RECT({ ui = api.ui })
    api.width = rect_api.width
    api.height = rect_api.height
end)

return true
