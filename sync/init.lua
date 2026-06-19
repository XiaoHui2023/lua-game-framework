---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.sync
---@field apis framework.sync.apis 同步 callback API 表
local M = {}
package.loaded[...] = M
---@type lib.reactive
local reactive = require "lib.reactive"
---@type framework.sync.apis
local apis = require ".apis"

local COUNT = 0
M.apis = apis

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
        apis.SEND({ head = param, data = data })
    end

    ---@param func fun(player:player, response:table):nil
    ---@return fun()
    o.add = function(func)
        return on_receive.add(func)
    end

    apis.LISTEN({ head = param, callback = function(player, data)
        on_receive(player, data)
    end })

    metatable.callable(o, o.run)

    return o
end

require ".apis"

return M
