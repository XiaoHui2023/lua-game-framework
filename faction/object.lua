---@class framework.faction
local g = require ".base"
local list = require "lib.list"
local factory = require("lib.reactive").factory

---@class faction.options
---@field default_stance faction.stance? 榛樿瀵瑰绔嬪満

---@param args? faction.options
---@return faction
g.create = function(args)
    args = args or {}
    args.default_stance = args.default_stance or "neutral"

    ---@class faction : factory
    local o = factory()

    -- 鍏ュ簱
    o.delete.mount(g.POOL_OBJECT.add(o))

    ---@type hook.set 榛樿瀵瑰绔嬪満<faction.stance>
    o.default_stance = o.factory.set(args.default_stance)

    ---@type hook.set 瀵瑰绔嬪満<table<faction, faction.stance>>
    o.stance = o.factory.set({})

    -- 寰楀埌瀵瑰绔嬪満
    ---@param fac faction 瀵规柟闃佃惀
    ---@return faction.stance 瀵瑰绔嬪満
    o.get_stance = function(fac)
        ---@type table<faction, faction.stance>
        local to_stance = o.stance()
        return to_stance[fac] or o.default_stance()
    end

    -- 璁剧疆瀵瑰绔嬪満
    ---@param fac faction 瀵规柟闃佃惀
    ---@param stance faction.stance 瀵瑰绔嬪満
    o.set_stance = function(fac, stance)
        ---@type table<faction, faction.stance>
        local to_stance = o.stance()
        to_stance[fac] = stance
        o.stance.set(to_stance)
    end

    ---@param fac faction 瀵规柟闃佃惀
    ---@return boolean 杩斿洖鏄惁鍙嬪ソ
    o.is_friendly = function(fac)
        if o == fac then
            return true
        end

        -- 鏄惁鏄洘鍙?
        if o.get_stance(fac) == "friendly" then
            return true
        end

        return false
    end

    ---@param fac faction 瀵规柟闃佃惀
    ---@return boolean 杩斿洖鏄惁涓珛
    o.is_neutral = function(fac)
        if o == fac then
            return false
        end

        -- 鏄惁鏄腑绔?
        if o.get_stance(fac) == "neutral" then
            return true
        end

        return false
    end

    ---@param fac faction 瀵规柟闃佃惀
    ---@return boolean 杩斿洖鏄惁鏁屽
    o.is_hostile  = function(fac)
        if o == fac then
            return false
        end

        -- 鏄惁鏄晫浜?
        if o.get_stance(fac) == "hostile" then
            return true
        end

        return false
    end

    ---@return list<faction> 鎵€鏈夊悓鐩熼樀钀?
    o.ally = function()
        -- 澹版槑
        local facs = list()

        g.POOL_OBJECT().for_each(
            function(fac)
                if o.is_friendly(fac) then
                    facs.append(fac)
                end
            end
        )

        return facs
    end

    ---@return list<faction> 鎵€鏈夋晫瀵归樀钀?
    o.enemy = function()
        -- 澹版槑
        local facs = list()

        g.POOL_OBJECT().for_each(
            function(fac)
                if o.is_hostile(fac) then
                    facs.append(fac)
                end
            end
        )

        return facs
    end

    ---璁剧疆鍚岀洘锛堝鏂逛笉涓€瀹氬悓鐩燂級
    ---@param fac faction 瀵规柟闃佃惀
    ---@return nil
    o.set_friendly = function(fac)
        if o == fac then
            return
        end

        -- 涓嶉噸澶?
        if o.get_stance(fac) == "friendly" then
            return
        end

        o.set_stance(fac, "friendly")
    end

    ---璁剧疆鏁屽锛堝鏂逛笉涓€瀹氭晫瀵癸級
    ---@param fac faction 瀵规柟闃佃惀
    ---@return nil
    o.set_hostile = function(fac)
        if o == fac then
            return
        end

        if o.get_stance(fac) == "hostile" then
            return
        end

        o.set_stance(fac, "hostile")
    end

    -- 缁撶洘锛堝弻鍚戯級
    ---@param fac faction 瀵规柟闃佃惀
    ---@return nil
    o.ally_with = function(fac)
        o.set_friendly(fac)
        fac.set_friendly(o)
    end

    -- 鏁屽锛堝弻鍚戯級
    ---@param fac faction 瀵规柟闃佃惀
    ---@return nil
    o.hostile_with = function(fac)
        o.set_hostile(fac)
        fac.set_hostile(o)
    end

    ---璁剧疆涓珛
    ---@param fac faction 瀵规柟闃佃惀
    ---@return nil
    o.set_neutral = function(fac)
        if o == fac then
            return
        end

        if o.get_stance(fac) == "neutral" then
            return
        end

        o.set_stance(fac, "neutral")
    end

    return o
end


return g
