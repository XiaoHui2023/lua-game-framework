---@class jass.special_effect
local g = require "jass.special_effect"

local player = require "package.player"
local hook = require "package.hook"
local leakage = require "package.leakage"
local point = require "package.point"
local shoot = require "package.shoot"
local math = require("package.math")
local object = require("lib.object")

---@class jass.special_effect
---@field HEIGHT_OFFSET number 高度修正
g.HEIGHT_OFFSET = -250


---新建特效
---@class jass.special_effect.new
---@field art 路径
---@field p 绑定点（点特效），支持函数
---@field unit 绑定单位（单位特效）
---@field position （单位特效）部位字符串
---@field np 只有某个玩家看得到
---@field t 存活时间，零表示立刻删除，负数表示永久。默认0
---@field rubbish 是否移动到垃圾点。默认为否
---@field hide 刚生成时是否为隐藏状态，仅适用于点特效，默认否
---@field fresh 刚生成时是否刷新一下（在镜头中心生成），用于静态特效，默认否
g.new = function(k)
    ---@class special_effect : object
    local se = object.create(k)

    -- 默认值
    k.art = k.art or ""
    k.t = k.t or 0 -- 立刻删除
    k.hide = k.hide or 0
    k.fresh = k.fresh or 0
    k.rubbish = k.rubbish or 0

    -- 解包
    local data = {unit = k.unit, position = k.position or "origin"}
    local art = k.art
    local np = k.np
    local fresh = k.fresh
    local rubbish = k.rubbish
    local t = k.t

    -- 支持函数
    if type(k.p) == "function" then
        k.p = k.p()
    end

    -- art是特效的名称，尝试转换
    art = g.trans_path(art)

    -- 异步特效
    if player.async(np) then
        art = ""
    end

    ---@class o_special_effect
    ---@field add_del 添加删除
    ---@field del 删除
    se.add_del, se.del = hook.add_del()

    -- 绑定泄露检查
    se.add_del(leakage.add(se))

    ---@class o_special_effect
    ---@field set_art 设置特效路径
    ---@field get_art 得到特效路径
    se.set_art, se.get_art = hook.set_get(k.art)

    ---@class o_special_effect
    ---@field set_sen 设置特效数值
    ---@field get_sen 得到特效数值
    se.set_sen, se.get_sen = hook.set_get()

    ---@class o_special_effect
    ---@field get_hide 得到是否隐藏
    local set_hide, get_hide = hook.set_get(k.hide)
    se.get_hide = get_hide

    ---@class o_special_effect
    ---@field set_location 设置位置
    ---@field get_location 得到位置
    se.set_location, se.get_location = hook.set_get(k.p)

    -- 计算
    local is_point = (k.p ~= nil and 1) or 0

    --[[
        删除旧的特效

        会恢复速度。可以移动到垃圾点再删除
    ]]
    local del_old = function()
        -- 解包
        local sen = se.get_sen()

        -- 有才能删
        if sen == nil then
            return
        end

        --速度恢复
        se.speed(1)

        -- 移到垃圾点
        if rubbish then --移动
            se.move(shoot.get_center())
            se.move(point.get_rubbish())
        end

        -- 删除
        g.del(se.get_sen())
    end

    -- 绑定删除
    se.add_del(del_old)

    --[[
        重新生成特效，分为点特效和单位特效

        点特效在刷新时，会现在镜头中心生成
    ]]
    local new = function()
        -- 解包
        local p = se.get_location()

        -- 删除旧的特效
        del_old()

        -- 生成
        if is_point then
            -- 声明
            local sen

            -- 刷新生成/直接生成
            if fresh then
                -- 镜头中心
                local p_tmp = shoot.get_center()

                -- 点特效
                sen = g.add(art, p_tmp.x, p_tmp.y)

                -- 移动
                se.move(p)
            else
                -- 点特效
                sen = g.add(art, p.x, p.y)
            end

            -- 入库
            se.set_sen(sen)
        else
            -- 单位特效
            local sen = g.add_target(art, data.unit.get_u(), data.position)

            -- 入库
            se.set_sen(sen)
        end

        -- 立刻删除/延时删除
        if t == 0 then
            del_old()
        elseif t > 0 then
            se.add_del(
                Timer.delay(
                    t,
                    function()
                        del_old()
                    end
                )
            )
        end
    end

    ---@class o_special_effect
    ---@field move 移动到目标点（仅用于点特效） 距离小于1不会移动
    se.move = function(p)
        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 距离过小不移动
        if point.d(p, se.get_location()) < 1 then
            return
        end

        -- 参数
        local p = point.new(p)

        -- 设置属性
        se.set_location(p)

        -- 移动
        g.move(se.get_sen(), p.x, p.y)
    end

    ---@class o_special_effect
    ---@field get_scale_x 得到X轴缩放倍数
    local set_scale_x, get_scale_x = hook.set_get(1)
    se.get_scale_x = get_scale_x

    ---@class o_special_effect
    ---@field get_scale_y 得到Y轴缩放倍数
    local set_scale_y, get_scale_y = hook.set_get(1)
    se.get_scale_y = get_scale_y

    ---@class o_special_effect
    ---@field get_scale_z 得到Z轴缩放倍数
    local set_scale_z, get_scale_z = hook.set_get(1)
    se.get_scale_z = get_scale_z

    ---@class o_special_effect
    ---@field scale 缩放函数（仅用于点特效） x,y,z : 缩放倍数。也可以只填一个参数，三轴统一缩放
    se.scale = function(x, y, z)
        -- 默认值
        x = x or 1
        y = y or x
        z = z or x

        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 解包
        local xo = get_scale_x()
        local yo = get_scale_y()
        local zo = get_scale_z()

        -- 不重复
        if x == xo and y == yo and z == zo then
            return
        end

        -- 计算指定大小
        m_x = x / xo
        m_y = y / yo
        m_z = z / zo

        -- 设置
        set_scale_x(x)
        set_scale_y(y)
        set_scale_z(z)

        g.scale(se.get_sen(), m_x, m_y, m_z)
    end

    ---@class o_special_effect
    ---@field hide 隐藏/显示（仅用于点特效） is_hide : 是否隐藏。默认是
    se.hide = function(is_hide)
        -- 参数
        is_hide = is_hide or 1

        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 不重复
        if is_hide == se.get_hide() then
            return
        end

        -- 设置
        set_hide(is_hide)

        -- 隐藏/显示
        if is_hide then
            del_old()
        else
            new()
        end
    end

    ---@class o_special_effect
    ---@field hide 显示（仅用于点特效） 隐藏的反函数
    se.show = function(is_show)
        -- 参数
        is_show = is_show or 1

        -- 反向隐藏
        se.hide(math.invert(is_show))
    end

    ---@class o_special_effect
    ---@field get_speed 得到动画速度
    local set_speed, get_speed = hook.set_get(1)
    se.get_speed = get_speed

    ---@class o_special_effect
    ---@field speed 设置播放速度（仅用于点特效） r : 播放速度
    se.speed = function(r)
        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 不重复
        if r == get_speed() then
            return
        end

        -- 设置
        set_speed(r)

        return g.speed(se.get_sen(), r)
    end

    ---@class o_special_effect
    ---@field get_height 得到高度
    local set_height, get_height = hook.set_get(0)
    se.get_height = get_height

    ---@class o_special_effect
    ---@field h 设置高度（仅用于点特效） r : 高度
    se.h = function(r)
        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 不重复
        if r == get_height() then
            return
        end

        -- 设置
        set_height(r)

        -- 高度修正
        r = r + g.get_height_offset()

        return g.h(se.get_sen(), r)
    end

    ---@class o_special_effect
    ---@field get_angle 得到朝向
    local set_angle, get_angle = hook.set_get(0)
    se.get_angle = get_angle

    ---@class o_special_effect
    ---@field a 设置朝向（仅用于点特效） r : 朝向
    se.a = function(r)
        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 角度修正
        r = math.angle_rule(r)

        -- 不重复
        if r == get_angle() then
            return
        end

        -- 解包
        local r_o = get_angle()

        -- 设置
        set_angle(r)

        return g.z(se.get_sen(), r - r_o)
    end

    ---@class o_special_effect
    ---@field get_x 得到X轴数值
    local set_x, get_x = hook.set_get(0)
    se.get_x = get_x

    ---@class o_special_effect
    ---@field x 抬头角度（仅用于点特效） r : 朝向
    se.x = function(r)
        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 不重复
        if r == get_x() then
            return
        end

        -- 解包
        local r_o = get_x()
        local z_o = get_angle()

        -- 设置
        set_x(r)

        -- 应用
        g.z(se.get_sen(), -z_o)
        g.x(se.get_sen(), r - r_o)
        g.z(se.get_sen(), z_o)
    end

    ---@class o_special_effect
    ---@field get_y 得到Y轴数值
    local set_y, get_y = hook.set_get(0)
    se.get_y = get_y

    ---@class o_special_effect
    ---@field y 抬头角度（仅用于点特效） r : 朝向
    se.y = function(r)
        -- 点特效
        if is_point == 0 then
            return
        end

        -- 已创建
        if se.get_sen() == nil then
            return
        end

        -- 不重复
        if r == get_y() then
            return
        end

        -- 解包
        local r_o = get_y()
        local z_o = get_angle()

        -- 设置
        set_y(r)

        -- 应用
        g.z(se.get_sen(), -z_o)
        g.y(se.get_sen(), r - r_o)
        g.z(se.get_sen(), z_o)
    end

    ---@class o_special_effect
    ---@field z 水平旋转（仅用于点特效） r : 朝向
    se.z = function(r)
        return se.a(r)
    end

    -- 初始不隐藏则创建
    if get_hide() == 0 then
        new()
    end

    return se
end

return g