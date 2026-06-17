---@class framework.camera.apis
---@field LIMIT_IN_AREA lib.callback.api 限制本地玩家镜头只能在矩形区域内移动
---@field SET_DISTANCE lib.callback.api 设置本地镜头距离，并同步框架状态
---@field SET_YAW lib.callback.api 设置本地镜头导航角，并同步框架状态
---@field SET_PITCH lib.callback.api 设置本地镜头俯仰角，并同步框架状态
---@field SET_ROLL lib.callback.api 设置本地镜头滚角，并同步框架状态
---@field SET_POSITION lib.callback.api 将本地镜头移动到指定世界坐标
---@field SET_USER_CONTROL lib.callback.api 开启或关闭玩家手动移动镜头
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
---@field distance number 目标镜头距离，会按默认远近边界夹紧
---@field duration? number 可选，过渡时长，单位秒；省略时立即生效
---@type lib.callback.api
M.SET_DISTANCE = callback.api({ name = "camera.SET_DISTANCE" })

---@class framework.camera.api.SetYaw: lib.callback.instance
---@field yaw number 目标导航角
---@field duration? number 可选，过渡时长，单位秒；省略时立即生效
---@type lib.callback.api
M.SET_YAW = callback.api({ name = "camera.SET_YAW" })

---@class framework.camera.api.SetPitch: lib.callback.instance
---@field pitch number 目标俯仰角
---@field duration? number 可选，过渡时长，单位秒；省略时立即生效
---@type lib.callback.api
M.SET_PITCH = callback.api({ name = "camera.SET_PITCH" })

---@class framework.camera.api.SetRoll: lib.callback.instance
---@field roll number 目标滚角
---@field duration? number 可选，过渡时长，单位秒；省略时立即生效
---@type lib.callback.api
M.SET_ROLL = callback.api({ name = "camera.SET_ROLL" })

---@class framework.camera.api.SetPosition: lib.callback.instance
---@field position point 目标世界坐标
---@field duration? number 可选，移动时长，单位秒；省略时立即生效
---@type lib.callback.api
M.SET_POSITION = callback.api({ name = "camera.SET_POSITION" })

---@class framework.camera.api.SetUserControl: lib.callback.instance
---@field enable boolean 是否允许玩家手动移动镜头
---@type lib.callback.api
M.SET_USER_CONTROL = callback.api({ name = "camera.SET_USER_CONTROL" })

return M
