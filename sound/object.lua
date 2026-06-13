---@class models.sound
local g = require ".base"
---@type models.timer
local Timer = require "models.timer"

---@type any 记录上一个音效句柄
local LAST_HANDLE = nil

---@type table<any, boolean> 音效冷却库
local MAP_COOLDOWN = {}

---@type number 音效冷却间隔
local COOLDOWN_INTERVAL = 0.1

-- 播放声音
---@param sound any 声音文件
---@return fun() 返回停止这个音效的函数
local function play(sound)
    assert(sound ~= nil, "handle is nil")

    -- 冷却
    if MAP_COOLDOWN[sound] ~= nil then
        return function() end
    else
        MAP_COOLDOWN[sound] = true
    end

    -- 同名连放
    if LAST_HANDLE == sound then
        g.stop(LAST_HANDLE)
    end

    -- 播放
    local handle = g.play(sound)

    -- 记录对象
    LAST_HANDLE = handle

    return function()
        if MAP_COOLDOWN[sound] ~= nil then
            g.stop(handle)
            MAP_COOLDOWN[sound] = nil
        end
    end
end

---定义声音
---@param sound any|table<any> 声音文件
---@return sound 音效对象
g.define = function(sound)
    local sound_list
    if type(sound) == "table" then
        sound_list = sound
    else
        sound_list = { sound }
    end

    ---@class sound
    ---@operator call(...):fun()
    local o = {}
    
    ---@type table<userdata> 句柄列表
    o.sound_list = sound_list

    ---@type integer 句柄列表长度
    o.length = #sound_list

    assert(o.length > 0, "sound_list is empty")

    ---播放音效
    ---@return fun() 返回停止这个音效的函数
    o.play = function()
        local sound
        if o.length == 1 then
            sound = o.sound_list[1]
        else
            local list = o.sound_list
            local n = math.random(1, o.length)
            sound = list[n]
        end

        return play(sound)
    end

    -- ()
    metatable.callable(g, o.play)

    return o
end

---音效冷却时间
---保证同一音效不会瞬时大量播放
Timer.loop(
    COOLDOWN_INTERVAL,
    function()
        MAP_COOLDOWN = {}
    end
)

return g