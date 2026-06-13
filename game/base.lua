---@class models.game
---@field end_game fun() 结束游戏
local g = {}
---@type utils.hook
local hook = require "utils.hook"

---@type hook.event 警告事件（content）
g.ON_ALERT = hook.event()

-- 警告
---@param content string 警告内容
g.alert = function (content)
    g.ON_ALERT(content)
end

return g