---@class framework.sound
---@field play fun(sound: 字段说明
---@field stop fun(handle: sound.handle) 停止
---@field set_volume fun(handle: sound.handle, volume: number) 设置音量（百分比）
local M = {}

---@type framework.sound.apis
local apis = require ".apis"

M.apis = apis

local function emit(api, values)
    local instance = api:new(values)
    instance:emit()
    return instance
end

M.play = function(sound, is_loop)
    local api = emit(apis.PLAY, { sound = sound, is_loop = is_loop })
    assert(api.handle ~= nil, "framework.sound.play requires runtime backend")
    return api.handle
end

M.stop = function(handle)
    emit(apis.STOP, { handle = handle })
end

M.set_volume = function(handle, volume)
    emit(apis.SET_VOLUME, { handle = handle, volume = volume })
end

return M
