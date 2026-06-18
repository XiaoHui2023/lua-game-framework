---@class framework.projectile.apis
---@field ON_CREATE lib.callback.api
---@field ON_DESTROY lib.callback.api
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class projectile.Created
---@field projectile projectile
M.ON_CREATE = callback.api({ name = "projectile.ON_CREATE" })

---@class projectile.Destroyed
---@field projectile projectile
M.ON_DESTROY = callback.api({ name = "projectile.ON_DESTROY" })

return M
