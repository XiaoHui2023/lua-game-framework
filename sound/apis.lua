---@class framework.sound.apis
---@field PLAY lib.callback.api 播放本地音效并写回句柄
---@field STOP lib.callback.api 停止音效
---@field SET_VOLUME lib.callback.api 设置音效音量
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class sound.api.Play: lib.callback.instance
---@field sound any 音效资源
---@field is_loop boolean? 是否循环播放
---@field handle sound.handle? 运行时写回的音效句柄
---@type lib.callback.api
M.PLAY = callback.api({ name = "sound.PLAY" })

---@class sound.api.Handle: lib.callback.instance
---@field handle sound.handle 音效句柄
---@type lib.callback.api
M.STOP = callback.api({ name = "sound.STOP" })

---@class sound.api.SetVolume: lib.callback.instance
---@field handle sound.handle 音效句柄
---@field volume number 音量比例，范围 0 到 1
---@type lib.callback.api
M.SET_VOLUME = callback.api({ name = "sound.SET_VOLUME" })

return M
