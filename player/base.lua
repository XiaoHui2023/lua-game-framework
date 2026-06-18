---@class framework.player
---@field set_mouse_click_selection fun(handle: player.handle, enable: boolean) 为玩家开/关鼠标点选
---@field set_mouse_drag_selection fun(handle: player.handle, enable: boolean) 为玩家开/关鼠标框选
---@field set_mouse_wheel fun(handle: player.handle, enable: boolean) 为玩家开/关鼠标滚轮
---@field LOCAL_HANDLE any 本地玩家句柄
---@field LOCAL_ID number 本地玩家ID
---@field get_name fun(handle: player.handle): string 得到玩家名字
---@field get_state fun(handle: player.handle): player.state 得到玩家状态
---@field get_controller fun(handle: player.handle): player.controller 得到玩家控制者
---@field MAX_PLAYERS number 玩家上限
---@field get_color fun(id: number): color 得到玩家颜色
local M = {}
---@type framework.player.apis
local apis = require ".apis"
M.apis = apis
M.ID_TO_OBJECT = {}

---@enum player.controller 控制者
M.CONTROLLER = {
    HUMAN = "CONTROLLER_HUMAN", --人类
    AI = "CONTROLLER_AI", --电脑
    NIL = "CONTROLLER_NIL", --无
}

---@enum player.state 玩家状态
M.STATE = {
    PLAYING = "PLAYING", --正在游戏
    NIL = "NIL", --无
    LEFT = "LEFT", --离开
}

---     异步执行函数 
---     示范：
---     if player.async(id) then 
---         return 
---     end
---@param id? number 参数说明
---@return boolean 目标玩家返回值为false，其他为true
M.async = function(id)
    if id == nil then
        return false
    end
    if id == M.LOCAL_ID then
        return false
    end
    return true
end

local function emit(api, values)
    local instance = api:new(values)
    instance:emit()
    return instance
end

M.set_mouse_click_selection = function(handle, enable)
    emit(apis.SET_MOUSE_CLICK_SELECTION, { handle = handle, enable = enable })
end

M.set_mouse_drag_selection = function(handle, enable)
    emit(apis.SET_MOUSE_DRAG_SELECTION, { handle = handle, enable = enable })
end

M.set_mouse_wheel = function(handle, enable)
    emit(apis.SET_MOUSE_WHEEL, { handle = handle, enable = enable })
end

M.get_name = function(handle)
    local api = emit(apis.GET_NAME, { handle = handle })
    return api.name
end

M.get_state = function(handle)
    local api = emit(apis.GET_STATE, { handle = handle })
    return api.state
end

M.get_controller = function(handle)
    local api = emit(apis.GET_CONTROLLER, { handle = handle })
    return api.controller
end

M.get_color = function(id)
    local api = emit(apis.GET_COLOR, { id = id })
    return api.color
end

---@param func fun(player:player) 遍历回调
M.for_each = function(func)
    for i = 1, M.MAX_PLAYERS do
        local player = M.get(i)
        if player ~= nil then
            func(player)
        end
    end
end

---@param func fun(player:player) 人类玩家回调
M.for_each_human = function(func)
    M.for_each(function(player)
        if player.is_human() then
            func(player)
        end
    end)
end

---@param func fun(player:player) 在线人类玩家回调
M.for_each_online = function(func)
    M.for_each_human(function(player)
        if not player.is_exit() then
            func(player)
        end
    end)
end

---@return number 当前玩家对象数量
M.get_player_number = function()
    local count = 0
    M.for_each(function()
        count = count + 1
    end)
    return count
end

---@return player 本地玩家对象
M.get_local = function()
    return M.get(M.LOCAL_ID)
end

---@param id? number 玩家序号
---@return player?
M.get = function(id)
    id = id or M.LOCAL_ID
    return M.ID_TO_OBJECT[id]
end

return M
