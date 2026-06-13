---@class models.player
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
local g = {}

---@enum player.controller 控制者
g.CONTROLLER = {
    HUMAN = "CONTROLLER_HUMAN", --人类
    AI = "CONTROLLER_AI", --电脑
    NIL = "CONTROLLER_NIL", --无
}

---@enum player.state 玩家状态
g.STATE = {
    PLAYING = "PLAYING", --正在游戏
    NIL = "NIL", --无
    LEFT = "LEFT", --离开
}

---     异步执行函数 
---     示范：
---     if player.async(id) then 
---         return 
---     end
---@param id? number 要异步的玩家
---@return boolean 目标玩家返回值为false，其他为true
g.async = function(id)
    if id == nil then
        return false
    end
    if id == g.LOCAL_ID then
        return false
    end
    return true
end

return g