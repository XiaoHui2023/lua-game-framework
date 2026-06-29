---@type lib.callback
local callback = require "lib.callback"

---@class framework.hero.apis
local M = {}

M.SET_HERO = callback.api({ name = "hero.SET_HERO" })
M.ON_HERO_CHANGED = callback.api({ name = "hero.ON_HERO_CHANGED" })

return M
