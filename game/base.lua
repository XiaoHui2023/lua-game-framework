---@class framework.game
---@field apis framework.game.apis
---@field end_game fun()
local M = {}
---@type framework.game.apis
local apis = require ".apis"

M.apis = apis
M.ON_ALERT = apis.ON_ALERT

---@param content string
M.alert = function (content)
    M.ON_ALERT({ content = content })
end

M.end_game = function()
    apis.END_GAME({})
end

return M
