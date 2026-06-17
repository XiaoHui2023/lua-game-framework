---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.sound
local g = require ".base"
---@type framework.timer
local Timer = require "framework.timer"

---@type any 璁板綍涓婁竴涓煶鏁堝彞鏌?
local LAST_HANDLE = nil

---@type table<any, boolean> 闊虫晥鍐峰嵈搴?
local MAP_COOLDOWN = {}

---@type number 闊虫晥鍐峰嵈闂撮殧
local COOLDOWN_INTERVAL = 0.1

-- 鎾斁澹伴煶
---@param sound any 澹伴煶鏂囦欢
---@return fun() 杩斿洖鍋滄杩欎釜闊虫晥鐨勫嚱鏁?
local function play(sound)
    assert(sound ~= nil, "handle is nil")

    -- 鍐峰嵈
    if MAP_COOLDOWN[sound] ~= nil then
        return function() end
    else
        MAP_COOLDOWN[sound] = true
    end

    -- 鍚屽悕杩炴斁
    if LAST_HANDLE == sound then
        g.stop(LAST_HANDLE)
    end

    -- 鎾斁
    local handle = g.play(sound)

    -- 璁板綍瀵硅薄
    LAST_HANDLE = handle

    return function()
        if MAP_COOLDOWN[sound] ~= nil then
            g.stop(handle)
            MAP_COOLDOWN[sound] = nil
        end
    end
end

---瀹氫箟澹伴煶
---@param sound any|table<any> 澹伴煶鏂囦欢
---@return sound 闊虫晥瀵硅薄
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
    
    ---@type table<userdata> 鍙ユ焺鍒楄〃
    o.sound_list = sound_list

    ---@type integer 鍙ユ焺鍒楄〃闀垮害
    o.length = #sound_list

    assert(o.length > 0, "sound_list is empty")

    ---鎾斁闊虫晥
    ---@return fun() 杩斿洖鍋滄杩欎釜闊虫晥鐨勫嚱鏁?
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

---闊虫晥鍐峰嵈鏃堕棿
---淇濊瘉鍚屼竴闊虫晥涓嶄細鐬椂澶ч噺鎾斁
Timer.loop(
    COOLDOWN_INTERVAL,
    function()
        MAP_COOLDOWN = {}
    end
)

return g