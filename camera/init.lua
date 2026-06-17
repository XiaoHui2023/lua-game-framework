---@class framework.camera
---@field apis framework.camera.apis
---@field state framework.camera.state
---@field settings framework.camera.settings
local M = {
    ---@type framework.camera.apis
    apis = require ".apis",
    ---@type framework.camera.state
    state = require ".state",
    ---@type framework.camera.settings
    settings = require ".settings",
}

require ".impl"

return M
