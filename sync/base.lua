---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.sync
---@field send fun(head: string, data: table)
---@field listen fun(head: string, callback: fun(player:player, data: table))
local M = {}
---@type lib.reactive
local reactive = require "lib.reactive"

local COUNT = 0

local function get_y3()
    local ok, engine = pcall(require, "runtime.engine")
    if ok and engine.get ~= nil then
        local current = engine.get()
        if current ~= nil and current.y3 ~= nil then
            return current.y3
        end
    end

    return y3
end

M.send = function(head, data)
    get_y3().sync.send(head, data)
end

M.listen = function(head, callback)
    get_y3().sync.onSync(head, function(data, source)
        ---@type framework.player
        local Player = require "framework.player"
        callback(Player.ID_TO_OBJECT[source.id], data)
    end)
end

---@return string
local function gen_unique_parameter()
    local param = ""

    local function cal62(n)
        local sum = 62
        local c
        local mod = math.floor(n % sum)

        if mod <= 9 then
            c = string.char(string.byte("0") + mod)
        elseif mod <= 9 + 26 then
            c = string.char(string.byte("a") + mod - 10)
        else
            c = string.char(string.byte("A") + mod - 10 - 26)
        end

        param = c .. param

        if n >= sum then
            cal62(n / sum)
        end
    end

    cal62(COUNT)
    COUNT = COUNT + 1

    return param
end

---@return sync
M.register = function()
    local param = gen_unique_parameter()

    ---@type reactive.event<table>
    local on_send = reactive.event()

    ---@type reactive.event<player, table>
    local on_receive = reactive.event()

    ---@class sync
    ---@operator call(table):nil
    local o = {}

    ---@param data table
    o.run = function(data)
        on_send(data)
        M.send(param, data)
    end

    ---@param func fun(player:player, response:table):nil
    ---@return fun()
    o.add = function(func)
        return on_receive.add(func)
    end

    M.listen(param, function(player, data)
        on_receive(player, data)
    end)

    metatable.callable(o, o.run)

    return o
end

return M
