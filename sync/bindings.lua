---@type framework.sync
local sync = require ".base"
---@type models.player
local Player = require "models.player"

sync.send = function(head, data)
    y3.sync.send(head, data)
end

sync.listen = function(head, callback)
    y3.sync.onSync(head,function(data, source)
        ---@type player
        local player = Player.ID_TO_OBJECT[source.id]
        ---@cast data table
        callback(player,data)
    end)
end
