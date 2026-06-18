-- 为玩家挂载按键绑定集合，并提供按键绑定对象的创建、事件转发和销毁清理。
---@class framework.event
local event = require "..apis"
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.player
local Player = require "framework.player"
---@type framework.player.apis
local player_apis = Player.apis

---@class player
---@field key_bindings reactive.collection<event.key_binding> 玩家持有的按键绑定集合。

---@param player player
local function setup_key_bindings(player)
    if player.key_bindings ~= nil then
        return
    end

    player.key_bindings = reactive.collection()
end

player_apis.PLAYER_CREATED(function(payload)
    setup_key_bindings(payload.player)
end)

if type(Player.for_each) == "function" then
    Player.for_each(setup_key_bindings)
end

---@class event.key_binding.options
---@field player player 绑定所属玩家。
---@field name string 按键绑定名称。
---@field category? string 按键绑定分类。
---@field key event.key 按键。
---@field on_press_async? fun(input:event.input) 本地异步按下回调。
---@field on_release_async? fun(input:event.input) 本地异步抬起回调。
---@field on_press_sync? fun(input:event.input.sync) 同步后按下回调。
---@field on_release_sync? fun(input:event.input.sync) 同步后抬起回调。

---@param args event.key_binding.options
---@return event.key_binding
event.key_binding = function(args)
    args.category = args.category or ""
    args.on_press_async = args.on_press_async or function() end
    args.on_release_async = args.on_release_async or function() end
    args.on_press_sync = args.on_press_sync or function() end
    args.on_release_sync = args.on_release_sync or function() end

    ---@class event.key_binding : event.key_binding.options
    local o = args

    ---@type reactive.once_event
    o.delete = reactive.once_event()

    o.delete.add(event.ON_KEY_DOWN_ASYNC(function(api)
        local input = api.input
        if input.key ~= o.key then
            return
        end
        o.on_press_async(input)
    end))
    o.delete.add(event.ON_KEY_UP_ASYNC(function(api)
        local input = api.input
        if input.key ~= o.key then
            return
        end
        o.on_release_async(input)
    end))
    o.delete.add(event.ON_KEY_DOWN_SYNC(function(api)
        local input = api.input
        if input.key ~= o.key or input.player ~= o.player then
            return
        end
        o.on_press_sync(input)
    end))
    o.delete.add(event.ON_KEY_UP_SYNC(function(api)
        local input = api.input
        if input.key ~= o.key or input.player ~= o.player then
            return
        end
        o.on_release_sync(input)
    end))

    o.delete.mount(o.player.key_bindings.add(o))

    return o
end
