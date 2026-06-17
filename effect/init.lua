---@type lib.mathx
local math = require "lib.mathx"
---@class jass.special_effect
local g = require "jass.special_effect"

local player = require "package.player"
local hook = require "lib.reactive"
local factory = require "lib.reactive".factory
local leakage = require "package.leakage"
local point = require "package.point"
local shoot = require "package.shoot"
local math = require("package.math")

---@class jass.special_effect
---@field HEIGHT_OFFSET number 楂樺害淇
g.HEIGHT_OFFSET = -250


---鏂板缓鐗规晥
---@class jass.special_effect.new
---@field art 璺緞
---@field p 缁戝畾鐐癸紙鐐圭壒鏁堬級锛屾敮鎸佸嚱鏁?---@field unit 缁戝畾鍗曚綅锛堝崟浣嶇壒鏁堬級
---@field position 锛堝崟浣嶇壒鏁堬級閮ㄤ綅瀛楃涓?---@field np 鍙湁鏌愪釜鐜╁鐪嬪緱鍒?---@field t 瀛樻椿鏃堕棿锛岄浂琛ㄧず绔嬪埢鍒犻櫎锛岃礋鏁拌〃绀烘案涔呫€傞粯璁ゅ€?---@field rubbish 鏄惁绉诲姩鍒板瀮鍦剧偣銆傞粯璁や负 false
---@field hide 鍒氱敓鎴愭椂鏄惁涓洪殣钘忕姸鎬侊紝浠呴€傜敤浜庣偣鐗规晥锛岄粯璁ゅ惁
---@field fresh 鍒氱敓鎴愭椂鏄惁鍒锋柊涓€涓嬶紙鍦ㄩ暅澶翠腑蹇冪敓鎴愶級锛岀敤浜庨潤鎬佺壒鏁堬紝榛樿鍊?
g.new = function(k)
    k = k or {}

    ---@class special_effect: hook.factory
    local se = factory(k)
    se.set_class("effect")

    -- 榛樿鍊?
    k.art = k.art or ""
    k.t = k.t or 0 -- 绔嬪埢鍒犻櫎
    k.hide = k.hide or 0
    k.fresh = k.fresh or 0
    k.rubbish = k.rubbish or 0
    k.facing = k.facing or 0

    -- 瑙ｅ寘
    local data = {unit = k.unit, position = k.position or "origin"}
    local art = k.art
    local np = k.np
    local fresh = k.fresh
    local rubbish = k.rubbish
    local t = k.t

    -- 鏀寔鍑芥暟
    if type(k.p) == "function" then
        k.p = k.p()
    end

    -- art鏄壒鏁堢殑鍚嶇О锛屽皾璇曡浆鎹?
    art = g.trans_path(art)

    -- 寮傛鐗规晥
    if player.async(np) then
        art = ""
    end

    ---@class o_special_effect
    ---@field add_del 娣诲姞鍒犻櫎
    ---@field del 鍒犻櫎
    se.add_del, se.del = hook.add_del()

    -- 缁戝畾娉勯湶妫€鏌?    se.add_del(leakage.add(se))

    ---@class o_special_effect
    ---@field set_art 璁剧疆鐗规晥璺緞
    ---@field get_art 寰楀埌鐗规晥璺緞
    se.set_art, se.get_art = hook.set_get(k.art)

    ---@class o_special_effect
    ---@field set_sen 璁剧疆鐗规晥鏁板€?    ---@field get_sen 寰楀埌鐗规晥鏁板€?    se.set_sen, se.get_sen = hook.set_get()

    ---@class o_special_effect
    ---@field get_hide 寰楀埌鏄惁闅愯棌
    local set_hide, get_hide = hook.set_get(k.hide)
    se.get_hide = get_hide

    ---@class o_special_effect
    ---@field set_location 璁剧疆浣嶇疆
    ---@field get_location 寰楀埌浣嶇疆
    se.set_location, se.get_location = hook.set_get(k.p)
    se.position = se.factory.set(k.p)
    se.facing = se.factory.set(k.facing)

    -- 璁＄畻
    local is_point = (k.p ~= nil and 1) or 0

    --[[
        鍒犻櫎鏃х殑鐗规晥

        浼氭仮澶嶉€熷害銆傚彲浠ョЩ鍔ㄥ埌鍨冨溇鐐瑰啀鍒犻櫎
    ]]
    local del_old = function()
        -- 瑙ｅ寘
        local sen = se.get_sen()

        -- 鏈夋墠鑳藉垹
        if sen == nil then
            return
        end

        --閫熷害鎭㈠
        se.speed(1)

        -- 绉诲埌鍨冨溇鐐?
        if rubbish then --绉诲姩
            se.move(shoot.get_center())
            se.move(point.get_rubbish())
        end

        -- 鍒犻櫎
        g.del(se.get_sen())
    end

    -- 缁戝畾鍒犻櫎
    se.add_del(del_old)

    --[[
        閲嶆柊鐢熸垚鐗规晥锛屽垎涓虹偣鐗规晥鍜屽崟浣嶇壒鏁?
        鐐圭壒鏁堝湪鍒锋柊鏃讹紝浼氱幇鍦ㄩ暅澶翠腑蹇冪敓鎴?    ]]
    local new = function()
        -- 瑙ｅ寘
        local p = se.get_location()

        -- 鍒犻櫎鏃х殑鐗规晥
        del_old()

        -- 鐢熸垚
        if is_point then
            -- 澹版槑
            local sen

            -- 鍒锋柊鐢熸垚/鐩存帴鐢熸垚
            if fresh then
                -- 闀滃ご涓績
                local p_tmp = shoot.get_center()

                -- 鐐圭壒鏁?
                sen = g.add(art, p_tmp.x, p_tmp.y)

                -- 绉诲姩
                se.move(p)
            else
                -- 鐐圭壒鏁?
                sen = g.add(art, p.x, p.y)
            end

            -- 鍏ュ簱
            se.set_sen(sen)
        else
            -- 鍗曚綅鐗规晥
            local sen = g.add_target(art, data.unit.get_u(), data.position)

            -- 鍏ュ簱
            se.set_sen(sen)
        end

        -- 绔嬪埢鍒犻櫎/寤舵椂鍒犻櫎
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
    ---@field move 绉诲姩鍒扮洰鏍囩偣锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 璺濈灏忎簬1涓嶄細绉诲姩
    se.move = function(p)
        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 璺濈杩囧皬涓嶇Щ鍔?
        if point.d(p, se.get_location()) < 1 then
            return
        end

        -- 鍙傛暟
        local p = point.new(p)

        se.set_location(p)
        se.position.set(p)

        -- 绉诲姩
        g.move(se.get_sen(), p.x, p.y)
    end

    ---@class o_special_effect
    ---@field get_scale_x 寰楀埌X杞寸缉鏀惧€嶆暟
    local set_scale_x, get_scale_x = hook.set_get(1)
    se.get_scale_x = get_scale_x

    ---@class o_special_effect
    ---@field get_scale_y 寰楀埌Y杞寸缉鏀惧€嶆暟
    local set_scale_y, get_scale_y = hook.set_get(1)
    se.get_scale_y = get_scale_y

    ---@class o_special_effect
    ---@field get_scale_z 寰楀埌Z杞寸缉鏀惧€嶆暟
    local set_scale_z, get_scale_z = hook.set_get(1)
    se.get_scale_z = get_scale_z

    ---@class o_special_effect
    ---@field scale 缂╂斁鍑芥暟锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 x,y,z : 缂╂斁鍊嶆暟銆備篃鍙互鍙～涓€涓弬鏁帮紝涓夎酱缁熶竴缂╂斁
    se.scale = function(x, y, z)
        -- 榛樿鍊?
        x = x or 1
        y = y or x
        z = z or x

        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 瑙ｅ寘
        local xo = get_scale_x()
        local yo = get_scale_y()
        local zo = get_scale_z()

        -- 涓嶉噸澶?
        if x == xo and y == yo and z == zo then
            return
        end

        -- 璁＄畻鎸囧畾澶у皬
        m_x = x / xo
        m_y = y / yo
        m_z = z / zo

        -- 璁剧疆
        set_scale_x(x)
        set_scale_y(y)
        set_scale_z(z)

        g.scale(se.get_sen(), m_x, m_y, m_z)
    end

    ---@class o_special_effect
    ---@field hide 闅愯棌/鏄剧ず锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 is_hide : 鏄惁闅愯棌銆傞粯璁ゆ槸
    se.hide = function(is_hide)
        -- 鍙傛暟
        is_hide = is_hide or 1

        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 涓嶉噸澶?
        if is_hide == se.get_hide() then
            return
        end

        -- 璁剧疆
        set_hide(is_hide)

        -- 闅愯棌/鏄剧ず
        if is_hide then
            del_old()
        else
            new()
        end
    end

    ---@class o_special_effect
    ---@field hide 鏄剧ず锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 闅愯棌鐨勫弽鍑芥暟
    se.show = function(is_show)
        -- 鍙傛暟
        is_show = is_show or 1

        -- 鍙嶅悜闅愯棌
        se.hide(math.invert(is_show))
    end

    ---@class o_special_effect
    ---@field get_speed 寰楀埌鍔ㄧ敾閫熷害
    local set_speed, get_speed = hook.set_get(1)
    se.get_speed = get_speed

    ---@class o_special_effect
    ---@field speed 璁剧疆鎾斁閫熷害锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 r : 鎾斁閫熷害
    se.speed = function(r)
        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 涓嶉噸澶?
        if r == get_speed() then
            return
        end

        -- 璁剧疆
        set_speed(r)

        return g.speed(se.get_sen(), r)
    end

    ---@class o_special_effect
    ---@field get_height 寰楀埌楂樺害
    local set_height, get_height = hook.set_get(0)
    se.get_height = get_height

    ---@class o_special_effect
    ---@field h 璁剧疆楂樺害锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 r : 楂樺害
    se.h = function(r)
        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 涓嶉噸澶?
        if r == get_height() then
            return
        end

        -- 璁剧疆
        set_height(r)

        -- 楂樺害淇
        r = r + g.get_height_offset()

        return g.h(se.get_sen(), r)
    end

    ---@class o_special_effect
    ---@field get_angle 寰楀埌鏈濆悜
    local set_angle, get_angle = hook.set_get(0)
    se.get_angle = get_angle

    ---@class o_special_effect
    ---@field a 璁剧疆鏈濆悜锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 r : 鏈濆悜
    se.a = function(r)
        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 瑙掑害淇
        r = math.angle_rule(r)

        -- 涓嶉噸澶?
        if r == get_angle() then
            return
        end

        -- 瑙ｅ寘
        local r_o = get_angle()

        -- 璁剧疆
        set_angle(r)
        se.facing.set(r)

        return g.z(se.get_sen(), r - r_o)
    end

    ---@class o_special_effect
    ---@field get_x 寰楀埌X杞存暟鍊?
    local set_x, get_x = hook.set_get(0)
    se.get_x = get_x

    ---@class o_special_effect
    ---@field x 鎶ご瑙掑害锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 r : 鏈濆悜
    se.x = function(r)
        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 涓嶉噸澶?
        if r == get_x() then
            return
        end

        -- 瑙ｅ寘
        local r_o = get_x()
        local z_o = get_angle()

        -- 璁剧疆
        set_x(r)

        -- 搴旂敤
        g.z(se.get_sen(), -z_o)
        g.x(se.get_sen(), r - r_o)
        g.z(se.get_sen(), z_o)
    end

    ---@class o_special_effect
    ---@field get_y 寰楀埌Y杞存暟鍊?
    local set_y, get_y = hook.set_get(0)
    se.get_y = get_y

    ---@class o_special_effect
    ---@field y 鎶ご瑙掑害锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 r : 鏈濆悜
    se.y = function(r)
        -- 鐐圭壒鏁?
        if is_point == 0 then
            return
        end

        -- 宸插垱寤?
        if se.get_sen() == nil then
            return
        end

        -- 涓嶉噸澶?
        if r == get_y() then
            return
        end

        -- 瑙ｅ寘
        local r_o = get_y()
        local z_o = get_angle()

        -- 璁剧疆
        set_y(r)

        -- 搴旂敤
        g.z(se.get_sen(), -z_o)
        g.y(se.get_sen(), r - r_o)
        g.z(se.get_sen(), z_o)
    end

    ---@class o_special_effect
    ---@field z 姘村钩鏃嬭浆锛堜粎鐢ㄤ簬鐐圭壒鏁堬級 r : 鏈濆悜
    se.z = function(r)
        return se.a(r)
    end

    -- 鍒濆涓嶉殣钘忓垯鍒涘缓
    if get_hide() == 0 then
        new()
    end

    return se
end

return g
