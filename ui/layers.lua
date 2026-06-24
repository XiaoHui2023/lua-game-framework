---@type framework.ui.apis
local apis = require ".apis"

---@class framework.ui.layers
---@field LAYER framework.ui.layer.registry UI 分层注册表
local M = {}

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

---@param name framework.ui.layer_name UI 分层名称
---@return framework.ui.handle? handle UI 分层句柄
function M.get(name)
    return M.LAYER[name]
end

return M
