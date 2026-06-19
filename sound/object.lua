---@type lib.metatablex
local metatable = require "lib.metatablex"
---@class framework.sound
local M = require "framework.sound"
---@type framework.sound.apis
local apis = require ".apis"
---@type framework.timer
local Timer = require "framework.timer"

---@type any
local LAST_HANDLE = nil

---@type table<any,
local MAP_COOLDOWN = {}

---@type number
local COOLDOWN_INTERVAL = 0.1

---@param sound any 参数说明
---@return fun() 返回值
local function play(sound)
    assert(sound ~= nil, "handle is nil")

    if MAP_COOLDOWN[sound] ~= nil then
        return function() end
    else
        MAP_COOLDOWN[sound] = true
    end

    if LAST_HANDLE == sound then
        apis.STOP({ handle = LAST_HANDLE })
    end

    local api = apis.PLAY({ sound = sound })
    assert(api.handle ~= nil, "framework.sound.define requires runtime backend")
    local handle = api.handle

    -- 璁板綍瀵硅薄
    LAST_HANDLE = handle

    return function()
        if MAP_COOLDOWN[sound] ~= nil then
            apis.STOP({ handle = handle })
            MAP_COOLDOWN[sound] = nil
        end
    end
end

---瀹氫箟澹伴煶
---@param sound any|table<any> 参数说明
---@return sound 返回值
M.define = function(sound)
    local sound_list
    if type(sound) == "table" then
        sound_list = sound
    else
        sound_list = { sound }
    end

    ---@class sound
    ---@operator call(...):fun()
    local o = {}
    
    ---@type table<userdata>
    o.sound_list = sound_list

    ---@type integer
    o.length = #sound_list

    assert(o.length > 0, "sound_list is empty")

    ---@return fun() 返回值
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
    metatable.callable(M, o.play)

    return o
end

Timer.loop(
    COOLDOWN_INTERVAL,
    function()
        MAP_COOLDOWN = {}
    end
)

return M
