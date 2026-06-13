---@class models.player
local g = require ".base"
local factory = require "models.factory"
---@type utils.hook
local hook = require "utils.hook"
---@type colorlib
local color = require "color"

---@type table 玩家对象映射表<number, player>
g.ID_TO_OBJECT = {}

---创建玩家
---@param id number 玩家序号（1~16）
---@return player? 玩家对象
local function create(id)
    id = id or g.LOCAL_ID
    assert(id >= 1 and id <= 16, "玩家序号必须在1~16之间")

    ---@type player.handle 玩家句柄
    local handle = y3.player(id)

    if handle == nil then
        return nil
    end

    ---@class player: factory
    local o = factory({
        name=g.get_name(handle),
    })

    -- 设置玩家对象映射表
    g.ID_TO_OBJECT[id] = o

    -- 设置类名
    o.set_class("player")

    ---@type hook.set 玩家序号<number>
    o.id = o.factory.set(id)

    ---@type hook.set 玩家句柄<number>
    o.handle = o.factory.set(handle)

    ---@type hook.set 控制者<player.controller>
    o.controller = o.factory.set(g.get_state(handle))

    ---@type hook.set 颜色<color>
    o.color = o.factory.set(g.get_color(id))

    ---@type hook.computed 上色后的名字<string>
    o.name_colored = o.factory.computed(function()
        return color.render(o.color(),o.name())
    end)

    ---@type hook.set 是否离开游戏<boolean>
    o.is_exit = o.factory.set(false)

    ---@type hook.computed 是否是人类<boolean>
    o.is_human = o.factory.computed(function()
        return o.controller() == g.CONTROLLER.HUMAN
    end)

    ---@type hook.computed 是否是电脑<boolean>
    o.is_ai = o.factory.computed(function()
        return o.controller() == g.CONTROLLER.AI
    end)

    ---@type hook.computed 是否是无控制者<boolean>
    o.is_nil = o.factory.computed(function()
        return o.controller() == g.CONTROLLER.NIL
    end)

    ---@type hook.event 玩家退出事件
    o.on_exit = hook.event()

    ---异步执行
    ---@param func fun() 执行函数
    ---@return nil
    o.async = function(func)
        if g.async(o.id()) then
            return
        end

        func()
    end

    ---玩家退出
    ---@return nil
    o.exit = function()
        o.is_exit.set(true)
        o.on_exit.run()
    end

    -- 注册域
    o.factory.register_hook_fields()

    return o
end

-- 注册玩家属性
---@param on_register fun(player:player) 注册函数
g.attach_behavior = function(on_register)
    g.for_each(function(player)
        on_register(player)
    end)
end

---遍历所有玩家
---@param func fun(player:player) 遍历函数
g.for_each = function(func)
    for i = 1, g.MAX_PLAYERS do
        local player = g.get(i)
        if player ~= nil then
            func(player)
        end
    end
end

-- 遍历所有人类玩家
---@param func fun(player:player) 遍历函数
g.for_each_human = function(func)
    g.for_each(function(player)
        if player.is_human() then
            func(player)
        end
    end)
end

-- 遍历所有在线玩家（人类）
---@param func fun(player:player) 遍历函数
g.for_each_online = function(func)
    g.for_each_human(function(player)
        if not player.is_exit() then
            func(player)
        end
    end)
end

---得到所有未离开的人类玩家数量
---@return number 未离开的人类玩家数量
g.get_player_number = function()
    local count = 0
    g.for_each(function()
        count = count + 1
    end)
    return count
end

---得到本地玩家
---@return player 本地玩家
g.get_local = function()
    return g.get(g.LOCAL_ID)
end

---得到玩家对象
---@param id number 玩家序号
---@return player 玩家对象
g.get = function(id)
    id = id or g.LOCAL_ID
    return g.ID_TO_OBJECT[id]
end

-- 初始化玩家
for id = 1, g.MAX_PLAYERS do
    create(id)
end

-- ()
metatable.callable(g, g.get)

return g
