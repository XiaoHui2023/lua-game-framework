---@class core.movement
local g = {}

---@class core.movement.data 移动数据
---@field origin_pos point 原始坐标（本帧开始时的位置）
---@field origin_z number 原始高度
---@field delta_pos point 水平位移（XY平面的相对位移）
---@field delta_z number 高度位移（Z轴的相对位移）
---@field facing number 朝向（角度）
---@field dt number 时间增量（本帧时长）

---@class core.movement.result
---@field data core.movement.data 数据
---@field final_pos point 最终坐标
---@field final_z number 最终高度

return g