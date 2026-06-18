---@class framework.projectile.apis
---@field ON_CREATE lib.callback.api
---@field ON_DESTROY lib.callback.api
---@field CREATE_EFFECT lib.callback.api 创建弹道特效句柄
---@field REMOVE lib.callback.api 移除弹道特效句柄
---@field SET_POSITION lib.callback.api 设置弹道特效位置
---@field SET_FACING lib.callback.api 设置弹道特效朝向
---@field SET_HEIGHT lib.callback.api 设置弹道特效高度
---@field SET_SCALE lib.callback.api 设置弹道特效缩放
---@field SET_ANIMATION_SPEED lib.callback.api 设置弹道特效动画速度
---@field SET_VISIBLE lib.callback.api 设置弹道特效可见性
local M = {}
---@type lib.callback
local callback = require "lib.callback"

---@class projectile.Created
---@field projectile projectile
M.ON_CREATE = callback.api({ name = "projectile.ON_CREATE" })

---@class projectile.Destroyed
---@field projectile projectile
M.ON_DESTROY = callback.api({ name = "projectile.ON_DESTROY" })

---@class projectile.api.CreateEffect
---@field effect any 特效资源
---@field position point 创建位置
---@field facing number? 朝向角度
---@field scale number? 整体缩放
---@field height number? 离地高度
---@field duration number? 持续时间
---@field handle projectile.effect_handle? 运行时写回的特效句柄
M.CREATE_EFFECT = callback.api({ name = "projectile.CREATE_EFFECT" })

---@class projectile.api.Handle
---@field handle projectile.effect_handle 特效句柄
M.REMOVE = callback.api({ name = "projectile.REMOVE" })

---@class projectile.api.SetPosition
---@field handle projectile.effect_handle 特效句柄
---@field position point 世界坐标
M.SET_POSITION = callback.api({ name = "projectile.SET_POSITION" })

---@class projectile.api.SetFacing
---@field handle projectile.effect_handle 特效句柄
---@field facing number 朝向角度
M.SET_FACING = callback.api({ name = "projectile.SET_FACING" })

---@class projectile.api.SetHeight
---@field handle projectile.effect_handle 特效句柄
---@field height number 离地高度
M.SET_HEIGHT = callback.api({ name = "projectile.SET_HEIGHT" })

---@class projectile.api.SetScale
---@field handle projectile.effect_handle 特效句柄
---@field scale_x number X 轴缩放
---@field scale_y number? Y 轴缩放
---@field scale_z number? Z 轴缩放
M.SET_SCALE = callback.api({ name = "projectile.SET_SCALE" })

---@class projectile.api.SetAnimationSpeed
---@field handle projectile.effect_handle 特效句柄
---@field speed number 动画速度
M.SET_ANIMATION_SPEED = callback.api({ name = "projectile.SET_ANIMATION_SPEED" })

---@class projectile.api.SetVisible
---@field handle projectile.effect_handle 特效句柄
---@field visible boolean 是否可见
M.SET_VISIBLE = callback.api({ name = "projectile.SET_VISIBLE" })

return M
