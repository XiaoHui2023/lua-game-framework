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
---@field z? number 字段说明

---@alias visual_effect.handle Particle 特效句柄
---@alias visual_effect.target point|unit.handle 特效创建目标，可以是世界坐标或单位句柄

---@class visual_effect.options
---@field socket? string 字段说明
---@field angle? number 字段说明
---@field scale? number 字段说明
---@field duration? number 字段说明
---@field time? number 字段说明
---@field height? number 字段说明
---@field immediate? boolean 字段说明
---@field follow_rotation? number 字段说明
---@field follow_scale? boolean 字段说明
---@field detach? boolean 字段说明

require ".impl"

return M
