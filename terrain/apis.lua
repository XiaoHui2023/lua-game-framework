---@class framework.terrain.apis
---@field SET_TEXTURE lib.callback.api 设置地表贴图
---@field SET_COLLISION lib.callback.api 设置地面碰撞
---@field GET_COLLISION_SIZE lib.callback.api 查询默认碰撞尺寸
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class terrain.api.SetTexture: lib.callback.instance
---@field position point 世界坐标
---@field texture any 地表贴图资源
---@field range number? 应用范围
---@type lib.callback.api
M.SET_TEXTURE = callback.api({ name = "terrain.SET_TEXTURE" })

---@class terrain.api.SetCollision: lib.callback.instance
---@field position point 世界坐标
---@type lib.callback.api
M.SET_COLLISION = callback.api({ name = "terrain.SET_COLLISION" })

---@class terrain.api.GetCollisionSize: lib.callback.instance
---@field size number? 运行时写回的碰撞尺寸
---@type lib.callback.api
M.GET_COLLISION_SIZE = callback.api({ name = "terrain.GET_COLLISION_SIZE" })

return M
