---@type models.timer
local g = require ".base"

g.create = function(interval, func)
    local timer = y3.timer.loop(interval, function (timer, count)
        func()
    end)
    return function()
        if timer and timer.remove then
            timer:remove()
        elseif timer and timer.pause then
            timer:pause()
        end
    end
end

return g
