---@class framework.camera.apis
---@field LIMIT_IN_AREA lib.callback.api 限制镜头到指定区域
---@field SET_DISTANCE lib.callback.api 设置镜头距离
---@field SET_YAW lib.callback.api 设置镜头偏航角
---@field SET_PITCH lib.callback.api 设置镜头俯仰角
---@field SET_ROLL lib.callback.api 设置镜头翻滚角
---@field SET_POSITION lib.callback.api 设置镜头目标位置
---@field SET_USER_CONTROL lib.callback.api 设置玩家镜头控制状态
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class framework.camera.api.LimitInArea: lib.callback.instance
---@field position point 限制区域中心点
---@field width number 限制区域宽度
---@field height number 限制区域高度
---@type lib.callback.api
M.LIMIT_IN_AREA = callback.api({ name = "camera.LIMIT_IN_AREA" })

---@class framework.camera.api.SetDistance: lib.callback.instance
---@field distance number 目标镜头距离
---@field duration? number 过渡时间
---@type lib.callback.api
M.SET_DISTANCE = callback.api({ name = "camera.SET_DISTANCE" })

---@class framework.camera.api.SetYaw: lib.callback.instance
---@field yaw number 目标导航角
---@field duration? number 过渡时间
---@type lib.callback.api
M.SET_YAW = callback.api({ name = "camera.SET_YAW" })

---@class framework.camera.api.SetPitch: lib.callback.instance
---@field pitch number 目标俯仰角
---@field duration? number 过渡时间
---@type lib.callback.api
M.SET_PITCH = callback.api({ name = "camera.SET_PITCH" })

---@class framework.camera.api.SetRoll: lib.callback.instance
---@field roll number 目标滚角
---@field duration? number 过渡时间
---@type lib.callback.api
M.SET_ROLL = callback.api({ name = "camera.SET_ROLL" })

---@class framework.camera.api.SetPosition: lib.callback.instance
---@field position point 目标世界坐标
---@field duration? number 过渡时间
---@type lib.callback.api
M.SET_POSITION = callback.api({ name = "camera.SET_POSITION" })

---@class framework.camera.api.SetUserControl: lib.callback.instance
---@field enable boolean 是否允许玩家控制镜头
---@type lib.callback.api
M.SET_USER_CONTROL = callback.api({ name = "camera.SET_USER_CONTROL" })

return M
