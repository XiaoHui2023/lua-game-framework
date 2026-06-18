---@class models.camera
---@field limit_in_area fun(position:point,width:number,height:number) 字段说明
---@field set_user_control fun(enable:boolean) 设置用户控制使能
---@field normal fun(duration?:number) 字段说明
---@field reset fun(duration?:number) 字段说明
---@field scroll fun(distance:number,duration?:number) 字段说明
---@field scroll_up fun() 视角向上滚动一次
---@field scroll_down fun() 视角向下滚动一次
---@field set_distance fun(distance:number,duration?:number) 字段说明
---@field set_yaw fun(yaw:number,duration?:number) 字段说明
---@field set_pitch fun(pitch:number,duration?:number) 字段说明
---@field set_roll fun(roll:number,duration?:number) 字段说明
---@field set_position fun(position:point,duration?:number) 字段说明
---@field distance number 字段说明
---@field yaw number 字段说明
---@field pitch number 字段说明
---@field roll number 字段说明
local M = {}
---@type utils.hook
local hook = require "utils.hook"

---@type hook.semaphore 用户控制
M.USER_CONTROL = hook.semaphore()

---@type hook.set
M.DISTANCE = hook.set(0)

return M
