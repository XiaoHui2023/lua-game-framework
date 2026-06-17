---@class framework.game
---@field end_game fun()
local g = {}
---@type framework.game.apis
local apis = require ".apis"

g.ON_ALERT = apis.ON_ALERT

---@param content string
g.alert = function (content)
    g.ON_ALERT({ content = content })
end

return g
