---@class framework.sound
---@field apis framework.sound.apis 声音 callback API 表
local M = {}
package.loaded[...] = M

---@type framework.sound.apis
local apis = require ".apis"

M.apis = apis
M.settings = require ".settings"

require ".object"

return M
