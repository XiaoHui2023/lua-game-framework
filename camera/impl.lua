-- 注册镜头框架的纯状态处理：夹紧距离边界，并把角度、距离、玩家控制开关写入 camera.state。
---@type framework.camera.apis
local apis = require ".apis"
---@type framework.camera.state
local state = require ".state"
---@type framework.camera.settings
local settings = require ".settings"

---@param api framework.camera.api.SetDistance
local function on_set_distance(api)
    local min_distance = settings.DEFAULT_NEAR_DISTANCE
    local max_distance = settings.DEFAULT_FAR_DISTANCE
    if min_distance > max_distance then
        min_distance, max_distance = max_distance, min_distance
    end
    if api.distance < min_distance then
        api.distance = min_distance
    elseif api.distance > max_distance then
        api.distance = max_distance
    end
    state.distance = api.distance
end

---@param api framework.camera.api.SetYaw
local function on_set_yaw(api)
    state.yaw = api.yaw
end

---@param api framework.camera.api.SetPitch
local function on_set_pitch(api)
    state.pitch = api.pitch
end

---@param api framework.camera.api.SetRoll
local function on_set_roll(api)
    state.roll = api.roll
end

---@param api framework.camera.api.SetUserControl
local function on_set_user_control(api)
    state.user_control_enabled = api.enable and true or false
end

apis.SET_DISTANCE(on_set_distance)
apis.SET_YAW(on_set_yaw)
apis.SET_PITCH(on_set_pitch)
apis.SET_ROLL(on_set_roll)
apis.SET_USER_CONTROL(on_set_user_control)
