---@class framework.visual_effect.apis
---@field CREATE lib.callback.api 创建特效，并把运行时句柄写回 payload.handle
---@field REMOVE lib.callback.api 移除指定特效句柄
---@field SET_POSITION lib.callback.api 移动指定特效到世界坐标
---@field SET_HEIGHT lib.callback.api 设置指定特效的离地高度
---@field SET_ROTATION lib.callback.api 设置指定特效的三轴旋转
---@field SET_FACING lib.callback.api 设置指定特效的朝向角度
---@field SET_SCALE lib.callback.api 设置指定特效的三轴缩放
---@field SET_COLOR lib.callback.api 设置指定特效的颜色与透明度
---@field SET_ANIMATION_SPEED lib.callback.api 设置指定特效的动画播放速度
---@field SET_DURATION lib.callback.api 字段说明
---@field SET_VISIBLE lib.callback.api 设置指定特效是否可见
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class framework.visual_effect.api.Create: lib.callback.instance
---@field key any 特效资源标识；通常来自 assets.effect
---@field target visual_effect.target 特效创建目标，可以是世界坐标或单位句柄
---@field options visual_effect.options 创建特效时使用的可选参数
---@field handle? visual_effect.handle 字段说明
---@type lib.callback.api
M.CREATE = callback.api({ name = "visual_effect.CREATE" })

---@class framework.visual_effect.api.Handle: lib.callback.instance
---@field handle visual_effect.handle 需要操作的特效句柄

---@class framework.visual_effect.api.SetPosition: framework.visual_effect.api.Handle
---@field position point 目标世界坐标
---@type lib.callback.api
M.SET_POSITION = callback.api({ name = "visual_effect.SET_POSITION" })

---@class framework.visual_effect.api.SetHeight: framework.visual_effect.api.Handle
---@field height number 目标离地高度
---@type lib.callback.api
M.SET_HEIGHT = callback.api({ name = "visual_effect.SET_HEIGHT" })

---@class framework.visual_effect.api.SetRotation: framework.visual_effect.api.Handle
---@field x? number 字段说明
---@field y? number 字段说明
---@field z? number 字段说明
---@type lib.callback.api
M.SET_ROTATION = callback.api({ name = "visual_effect.SET_ROTATION" })

---@class framework.visual_effect.api.SetFacing: framework.visual_effect.api.Handle
---@field facing number 目标朝向角度
---@type lib.callback.api
M.SET_FACING = callback.api({ name = "visual_effect.SET_FACING" })

---@class framework.visual_effect.api.SetScale: framework.visual_effect.api.Handle
---@field scale_x? number 字段说明
---@field scale_y? number 字段说明
---@field scale_z? number 字段说明
---@type lib.callback.api
M.SET_SCALE = callback.api({ name = "visual_effect.SET_SCALE" })

---@class framework.visual_effect.api.SetColor: framework.visual_effect.api.Handle
---@field color? color 字段说明
---@field alpha? number 字段说明
---@type lib.callback.api
M.SET_COLOR = callback.api({ name = "visual_effect.SET_COLOR" })

---@class framework.visual_effect.api.SetAnimationSpeed: framework.visual_effect.api.Handle
---@field speed number 动画播放速度倍率
---@type lib.callback.api
M.SET_ANIMATION_SPEED = callback.api({ name = "visual_effect.SET_ANIMATION_SPEED" })

---@class framework.visual_effect.api.SetDuration: framework.visual_effect.api.Handle
---@field duration number 字段说明
---@type lib.callback.api
M.SET_DURATION = callback.api({ name = "visual_effect.SET_DURATION" })

---@class framework.visual_effect.api.SetVisible: framework.visual_effect.api.Handle
---@field visible boolean 是否可见
---@type lib.callback.api
M.SET_VISIBLE = callback.api({ name = "visual_effect.SET_VISIBLE" })

---@type lib.callback.api
M.REMOVE = callback.api({ name = "visual_effect.REMOVE" })

return M
