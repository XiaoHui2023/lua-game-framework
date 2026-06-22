---@class framework.visual_effect
---@field apis framework.visual_effect.apis
---@field settings framework.visual_effect.settings
local M = {
    ---@type framework.visual_effect.apis
    apis = require ".apis",
    ---@type framework.visual_effect.settings
    settings = require ".settings",
}

---@class point
---@field x number 世界坐标 X
---@field y number 世界坐标 Y
---@field z? number 世界坐标 Z

---@alias visual_effect.handle Particle 特效句柄
---@alias visual_effect.target point|unit.handle 特效创建目标，可以是世界坐标或单位句柄

---@class visual_effect.options
---@field socket? string 挂载到单位时使用的插槽名
---@field angle? number 特效朝向角度
---@field scale? number 特效整体缩放
---@field duration? number 特效持续时间，负数表示不主动销毁
---@field time? number 特效播放起始时间
---@field height? number 坐标点创建时的离地高度
---@field immediate? boolean 是否立即创建并播放
---@field follow_rotation? number 跟随目标旋转的角度偏移
---@field follow_scale? boolean 是否跟随目标缩放
---@field detach? boolean 目标销毁或分离时是否保留特效

return M
