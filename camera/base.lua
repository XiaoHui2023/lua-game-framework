---@class models.camera
---@field limit_in_area fun(position:point,width:number,height:number) 限制镜头在区域
---@field set_user_control fun(enable:boolean) 设置用户控制使能
---@field normal fun(duration?:number) 设置为推荐视角
---@field reset fun(duration?:number) 复位镜头属性
---@field scroll fun(distance:number,duration?:number) 视角滚动到指定值
---@field scroll_up fun() 视角向上滚动一次
---@field scroll_down fun() 视角向下滚动一次
---@field set_distance fun(distance:number,duration?:number) 设置镜头距离
---@field set_yaw fun(yaw:number,duration?:number) 设置镜头导航角（绕Y轴的旋转角度）
---@field set_pitch fun(pitch:number,duration?:number) 设置镜头俯仰角（绕X轴的旋转角度）
---@field set_roll fun(roll:number,duration?:number) 设置镜头滚角（绕Z轴的旋转角度）
---@field set_position fun(position:point,duration?:number) 设置镜头位置
---@field distance number 当前镜头距离
---@field yaw number 当前镜头导航角
---@field pitch number 当前镜头俯仰角
---@field roll number 当前镜头滚角
local g = {}
---@type utils.hook
local hook = require "utils.hook"

---@type hook.semaphore 用户控制
g.USER_CONTROL = hook.semaphore()

---@type hook.set 当前镜头距离
g.DISTANCE = hook.set(0)

return g