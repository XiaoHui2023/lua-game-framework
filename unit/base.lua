---@class framework.unit
---@field new fun(key:any, position:point, player:player, facing?:number): unit.handle 创建单位
---@field kill fun(handle:unit.handle) 杀死单位
---@field remove fun(handle:unit.handle) 删除单位
---@field revive fun(handle:unit.handle) 复活单位
---@field command_stop fun(handle:unit.handle) 执行停止命令
---@field command fun(handle:unit.handle) 执行命令
---@field set_facing fun(handle:unit.handle, facing:number,duration?:number) 设置朝向
---@field get_facing fun(handle:unit.handle):number 获取朝向
---@field set_height fun(handle:unit.handle, height:number,duration?:number) 设置高度
---@field play_animation fun(handle:unit.handle, name:string, speed?:number, start_time?:number, end_time?:number, loop?:boolean, reset_on_end?:boolean, transition_time?:number, force_play?:boolean) 播放动画
---@field set_animation_speed fun(handle:unit.handle, speed:number) 设置动画速度
---@field set_move_type fun(handle:unit.handle, move_type:move_type) 设置移动类型
---@field replace_model fun(handle:unit.handle, key:any) 替换模型
---@field get_position fun(handle:unit.handle):point 获取位置
---@field set_collision_radius fun(handle:unit.handle, radius:number) 设置碰撞半径
---@field set_color fun(handle:unit.handle, enable:boolean, color:color, alpha:number) 设置颜色
---@field set_outline fun(handle:unit.handle, enable:boolean, color:color) 设置描边
---@field set_overlay fun(handle:unit.handle, enable:boolean, color:color) 设置覆盖
---@field teleport fun(handle:unit.handle,position:point) 传送（如果能到达）
---@field set_position fun(handle:unit.handle,position:point) 设置位置（不论是否能通行）
---@field enable_shadow fun(handle:unit.handle, enable:boolean) 设置阴影使能
---@field set_scale fun(handle:unit.handle, scale_x:number, scale_y?:number, scale_z?:number) 设置模型缩放
---@field set_animation_alternate fun(handle:unit.handle, name:string) 设置动画附加
---@field set_select_visible fun(handle:unit.handle, visible:boolean) 设置选择框可见性
---@field set_turning_speed fun(handle:unit.handle, speed:number) 设置转身速度
---@field select fun(handle:unit.handle,player:player.handle) 选中单位
---@field set_move_speed fun(handle:unit.handle, speed:number) 设置移动速度
---@field set_attack_speed fun(handle:unit.handle, speed:number) 设置攻击速度
---@field set_attack_interval fun(handle:unit.handle, interval:number) 设置攻击间隔
---@field set_attack_range fun(handle:unit.handle, range:number) 设置攻击范围
---@field set_turn_speed fun(handle:unit.handle, speed:number) 设置转身速度
local g = {}

---@type table<unit.handle, unit> 单位对象映射表
g.HANDLE_TO_OBJECT = {}

---@enum move_type
g.MOVE_TYPE = {
    LAND = "LAND", -- 地面
    AIR = "AIR", -- 空中
    NIL = "NIL", -- 无
}

return g
