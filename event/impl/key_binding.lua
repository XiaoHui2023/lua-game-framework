-- 为玩家挂载按键绑定集合，并提供按键绑定对象的创建、事件转发和销毁清理。
---@class framework.event
local g = require "..apis"
---@type lib.reactive
local hook = require "lib.reactive"
---@type framework.player
local Player = require "framework.player"

---@class player
---@field key_bindings hook.add<event.key_binding> 閿綅缁戝畾鍣?
-- 娉ㄥ唽鐜╁鍒涘缓浜嬩欢
Player.attach_behavior(
    ---@param player player
    function(player)
        player.key_bindings = hook.collection()
end)

---@class event.key_binding.options
---@field player player 鐜╁
---@field name string 閿綅鍚嶇О
---@field category? string 閿綅鍒嗙被
---@field key event.key 閿綅
---@field on_press_async? fun(input:event.input) 鎸変笅寮傛鍥炶皟
---@field on_release_async? fun(input:event.input) 鎶捣寮傛鍥炶皟
---@field on_press_sync? fun(input:event.input.sync) 鎸変笅鍚屾鍥炶皟
---@field on_release_sync? fun(input:event.input.sync) 鎶捣鍚屾鍥炶皟

-- 閿綅缁戝畾鍣?---@param args event.key_binding.options
---@return event.key_binding
g.key_binding = function(args)
    args.category = args.category or ''
    args.on_press_async = args.on_press_async or function() end
    args.on_release_async = args.on_release_async or function() end
    args.on_press_sync = args.on_press_sync or function() end
    args.on_release_sync = args.on_release_sync or function() end

    ---@class event.key_binding : event.key_binding.options
    local o = {}

    ---@type hook.once_event 鍒犻櫎
    o.delete = hook.once_event()

    -- 娣诲姞鍥炶皟
    o.delete.add(g.ON_KEY_DOWN_ASYNC(function(api)
        local input = api.input
        if input.key ~= o.key then
            return
        end
        o.on_press_async(input)
    end))
    o.delete.add(g.ON_KEY_UP_ASYNC(function(api)
        local input = api.input
        if input.key ~= o.key then
            return
        end
        o.on_release_async(input)
    end))
    o.delete.add(g.ON_KEY_DOWN_SYNC(function(api)
        local input = api.input
        if input.key ~= o.key or input.player ~= o.player then
            return
        end
        o.on_press_sync(input)
    end))
    o.delete.add(g.ON_KEY_UP_SYNC(function(api)
        local input = api.input
        if input.key ~= o.key or input.player ~= o.player then
            return
        end
        o.on_release_sync(input)
    end))

    -- 娣诲姞鍒扮帺瀹堕敭浣嶇粦瀹氬櫒
    o.delete.mount(o.player.key_bindings.add(o))

    return o
end
