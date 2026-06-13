---@type models.sync
local g = require ".base"
---@type models.player
local Player = require "models.player"

g.send = function(head, data)
    y3.sync.send(head, data)
end

g.listen = function(head, callback)
    y3.sync.onSync(head,function(data, source)
        ---@type player
        local player = Player.ID_TO_OBJECT[source.id]
        ---@cast data table
        callback(player,data)
    end)
end
