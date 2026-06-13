---@type models.timer
local g = require ".base"

g.create = function(interval, func)
    y3.timer.loop(interval, function (timer, count)
        func()
    end)
end

return g