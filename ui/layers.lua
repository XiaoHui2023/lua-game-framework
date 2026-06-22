---@class framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require ".apis"

---@type framework.ui.layer.registry
M.LAYER = {
    DEFAULT = nil,
    WINDOW = nil,
    HUD = nil,
    SYSTEM = nil,
    CINEMATIC = nil,
}

---@type table<framework.ui.layer_name, true>
local LAYER_NAMES = {
    DEFAULT = true,
    WINDOW = true,
    HUD = true,
    SYSTEM = true,
    CINEMATIC = true,
}

setmetatable(M.LAYER, {
    __index = function(layers, name)
        if not LAYER_NAMES[name] then
            return nil
        end

        local api = apis.CREATE({})
        assert(api.handle ~= nil, "framework.ui.LAYER requires runtime backend")
        local layer = api.handle
        rawset(layers, name, layer)
        return layer
    end,
})

return M
