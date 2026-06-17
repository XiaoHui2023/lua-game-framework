---@class framework.sound
---@field play fun(sound: any,is_loop?: boolean):sound.handle 播放。返回句柄
---@field stop fun(handle: sound.handle) 停止
---@field set_volume fun(handle: sound.handle, volume: number) 设置音量（百分比）
local g = {}

return g