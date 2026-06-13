---@type models.event
local g = require ".base"
---@type models.sync
local sync = require "models.sync"

---@type sync 鼠标移动同步器
local SYNC_MOUSE_MOVE = sync.register()
---@type sync 按键按下同步器
local SYNC_KEY_DOWN = sync.register()
---@type sync 按键抬起同步器
local SYNC_KEY_UP = sync.register()
---@type sync 鼠标按下同步器
local SYNC_MOUSE_DOWN = sync.register()
---@type sync 鼠标抬起同步器
local SYNC_MOUSE_UP = sync.register()

-- 异步发送鼠标移动
g.ON_MOUSE_MOVE_ASYNC.add(function(input)
    SYNC_MOUSE_MOVE(input)
end)
-- 异步发送按键按下
g.ON_KEY_DOWN_ASYNC.add(function(input)
    SYNC_KEY_DOWN(input)
end)
-- 异步发送按键抬起
g.ON_KEY_UP_ASYNC.add(function(input)
    SYNC_KEY_UP(input)
end)
-- 异步发送鼠标按下
g.ON_MOUSE_DOWN_ASYNC.add(function(input)
    SYNC_MOUSE_DOWN(input)
end)
-- 异步发送鼠标抬起
g.ON_MOUSE_UP_ASYNC.add(function(input)
    SYNC_MOUSE_UP(input)
end)

-- 同步接收鼠标移动
SYNC_MOUSE_MOVE.add(function(player, response)
    response.player = player
    g.ON_MOUSE_MOVE_SYNC(response)
end)
-- 同步接收按键按下
SYNC_KEY_DOWN.add(function(player, response)
    response.player = player
    g.ON_KEY_DOWN_SYNC(response)
end)
-- 同步接收按键抬起
SYNC_KEY_UP.add(function(player, response)
    response.player = player
    g.ON_KEY_UP_SYNC(response)
end)
-- 同步接收鼠标按下
SYNC_MOUSE_DOWN.add(function(player, response)
    response.player = player
    g.ON_MOUSE_DOWN_SYNC(response)
end)
-- 同步接收鼠标抬起
SYNC_MOUSE_UP.add(function(player, response)
    response.player = player
    g.ON_MOUSE_UP_SYNC(response)
end)