-- 把本地异步输入事件发到同步通道，再分发为带玩家信息的同步输入事件。
---@type framework.event
local M = require "..apis"
---@type framework.sync
local sync = require "framework.sync"

---@type sync 鼠标移动同步器
local SYNC_MOUSE_MOVE = sync.register()
---@type sync
local SYNC_KEY_DOWN = sync.register()
---@type sync
local SYNC_KEY_UP = sync.register()
---@type sync 鼠标按下同步器
local SYNC_MOUSE_DOWN = sync.register()
---@type sync 鼠标抬起同步器
local SYNC_MOUSE_UP = sync.register()

-- 异步发送鼠标移动
M.ON_MOUSE_MOVE_ASYNC(function(api)
    SYNC_MOUSE_MOVE(api.input)
end)
M.ON_KEY_DOWN_ASYNC(function(api)
    SYNC_KEY_DOWN(api.input)
end)
M.ON_KEY_UP_ASYNC(function(api)
    SYNC_KEY_UP(api.input)
end)
-- 异步发送鼠标按下
M.ON_MOUSE_DOWN_ASYNC(function(api)
    SYNC_MOUSE_DOWN(api.input)
end)
-- 异步发送鼠标抬起
M.ON_MOUSE_UP_ASYNC(function(api)
    SYNC_MOUSE_UP(api.input)
end)

-- 同步接收鼠标移动
SYNC_MOUSE_MOVE.add(function(player, response)
    response.player = player
    M.ON_MOUSE_MOVE_SYNC({ input = response })
end)
SYNC_KEY_DOWN.add(function(player, response)
    response.player = player
    M.ON_KEY_DOWN_SYNC({ input = response })
end)
SYNC_KEY_UP.add(function(player, response)
    response.player = player
    M.ON_KEY_UP_SYNC({ input = response })
end)
-- 同步接收鼠标按下
SYNC_MOUSE_DOWN.add(function(player, response)
    response.player = player
    M.ON_MOUSE_DOWN_SYNC({ input = response })
end)
-- 同步接收鼠标抬起
SYNC_MOUSE_UP.add(function(player, response)
    response.player = player
    M.ON_MOUSE_UP_SYNC({ input = response })
end)
