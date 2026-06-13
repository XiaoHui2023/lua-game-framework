---@class models.sync
---@field send fun(head: string, data: table) 发送同步数据（需要做好数据类型兼容）
---@field listen fun(head: string, callback: fun(player:player, data: table)) 监听同步数据（需要做好数据类型兼容）
local g = {}
---@type utils.hook
local hook = require "utils.hook"

-- 同步计数
local COUNT = 0

---得到一个不重复的字段
---@return string
local function gen_unique_parameter()
    local param = ""

    -- 按62进制压缩值
    local function cal62(n)
        -- 声明
        local sum = 62
        local c

        -- 计算
        local mod = math.floor(n % sum)

        -- 取值
        if mod <= 9 then
            c = string.char(string.byte("0") + mod)
        elseif mod <= 9 + 26 then
            c = string.char(string.byte("a") + mod - 10)
        else
            c = string.char(string.byte("A") + mod - 10 - 26)
        end

        -- 拼接
        param = c .. param

        -- 递归
        if n >= sum then
            cal62(n / sum)
        end
    end

    -- 62进制计算
    cal62(COUNT)

    -- ++
    COUNT = COUNT + 1

    return param
end

---注册同步触发器
---@return sync 同步事件对象
g.register = function()
    -- 生成字段
    local param = gen_unique_parameter()

    ---@type hook.event<table> 请求事件
    local on_send = hook.event()

    ---@type hook.event<player, table> 同步事件
    local on_receive = hook.event()

    ---@class sync
    ---@operator call(table):nil
    local o = {}

    -- 同步数据
    ---@param data table
    o.run = function(data)
        on_send(data)

        g.send(param, data)
    end

    ---添加同步动作
    ---@param func fun(player:player, response:table):nil 触发函数
    ---@return fun() 删除函数
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