---@class models.event
local g = require ".base"
---@type utils.hook
local hook = require "utils.hook"
---@type models.player
local Player = require "models.player"

---@class player
---@field key_bindings hook.add<event.key_binding> 键位绑定器

-- 注册玩家创建事件
Player.attach_behavior(
    ---@param player player
    function(player)
        player.key_bindings = hook.add()
end)

---@class event.key_binding.options
---@field player player 玩家
---@field name string 键位名称
---@field category? string 键位分类
---@field key event.key 键位
---@field on_press_async? fun(input:event.input) 按下异步回调
---@field on_release_async? fun(input:event.input) 抬起异步回调
---@field on_press_sync? fun(input:event.input.sync) 按下同步回调
---@field on_release_sync? fun(input:event.input.sync) 抬起同步回调

-- 键位绑定器
---@param args event.key_binding.options
---@return event.key_binding
g.key_binding = function(args)
    args.category = args.category or ''
    args.on_press_async = args.on_press_async or function() end
    args.on_release_async = args.on_release_async or function() end
    args.on_press_sync = args.on_press_sync or function() end
    args.on_release_sync = args.on_release_sync or function() end

    ---@class event.key_binding : event.key_binding.options
    local o = {}

    ---@type hook.once_event 删除
    o.delete = hook.once_event()

    -- 添加回调
    o.delete.add(g.ON_KEY_DOWN_ASYNC.add(function(input)
        if input.key ~= o.key then
            return
        end
        o.on_press_async(input)
    end))
    o.delete.add(g.ON_KEY_UP_ASYNC.add(function(input)
        if input.key ~= o.key then
            return
        end
        o.on_release_async(input)
    end))
    o.delete.add(g.ON_KEY_DOWN_SYNC.add(function(input)
        if input.key ~= o.key or input.player ~= o.player then
            return
        end
        o.on_press_sync(input)
    end))
    o.delete.add(g.ON_KEY_UP_SYNC.add(function(input)
        if input.key ~= o.key or input.player ~= o.player then
            return
        end
        o.on_release_sync(input)
    end))

    -- 添加到玩家键位绑定器
    o.delete.mount(o.player.key_bindings.add(o))

    return o
end