---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.sync
---@field send fun(head: string, data: table) 鍙戦€佸悓姝ユ暟鎹紙闇€瑕佸仛濂芥暟鎹被鍨嬪吋瀹癸級
---@field listen fun(head: string, callback: fun(player:player, data: table)) 鐩戝惉鍚屾鏁版嵁锛堥渶瑕佸仛濂芥暟鎹被鍨嬪吋瀹癸級
local g = {}
---@type lib.reactive
local hook = require "lib.reactive"

-- 鍚屾璁℃暟
local COUNT = 0

---寰楀埌涓€涓笉閲嶅鐨勫瓧绗︿覆
---@return string
local function gen_unique_parameter()
    local param = ""

    -- 32杩涘埗鍘嬬缉瀛楃涓?
    local function cal62(n)
        -- 澹版槑
        local sum = 62
        local c

        -- 璁＄畻
        local mod = math.floor(n % sum)

        -- 鍙栧€?
        if mod <= 9 then
            c = string.char(string.byte("0") + mod)
        elseif mod <= 9 + 26 then
            c = string.char(string.byte("a") + mod - 10)
        else
            c = string.char(string.byte("A") + mod - 10 - 26)
        end

        -- 鎷兼帴
        param = c .. param

        -- 閫掑綊
        if n >= sum then
            cal62(n / sum)
        end
    end

    -- 62杩涘埗璁＄畻
    cal62(COUNT)

    -- ++
    COUNT = COUNT + 1

    return param
end

---娉ㄥ唽鍚屾瑙﹀彂鍣?---@return sync 鍚屾浜嬩欢瀵硅薄
g.register = function()
    -- 鐢熸垚瀛楁
    local param = gen_unique_parameter()

    ---@type hook.event<table> 璇锋眰浜嬩欢
    local on_send = hook.event()

    ---@type hook.event<player, table> 鍚屾浜嬩欢
    local on_receive = hook.event()

    ---@class sync
    ---@operator call(table):nil
    local o = {}

    -- 鍚屾鏁版嵁
    ---@param data table
    o.run = function(data)
        on_send(data)

        g.send(param, data)
    end

    ---娣诲姞鍚屾鍔ㄤ綔
    ---@param func fun(player:player, response:table):nil 瑙﹀彂鍑芥暟
    ---@return fun() 鍒犻櫎鍑芥暟
    o.add = function(func)
        return on_receive.add(func)
    end
    
    g.listen(param, function(player, data)
        on_receive(player, data)
    end)

    -- ()
    metatable.callable(o, o.run)

    return o
end

return g
