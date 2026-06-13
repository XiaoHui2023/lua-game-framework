---@class models.faction
local g = require ".base"
local list = require "list"
local factory = require "models.factory"

---@class faction.options
---@field default_stance faction.stance? 默认对外立场

---@param args? faction.options
---@return faction
g.create = function(args)
    args = args or {}
    args.default_stance = args.default_stance or "neutral"

    ---@class faction : factory
    local o = factory()

    -- 入库
    o.delete.mount(g.POOL_OBJECT.add(o))

    ---@type hook.set 默认对外立场<faction.stance>
    o.default_stance = o.factory.set(args.default_stance)

    ---@type hook.set 对外立场<table<faction, faction.stance>>
    o.stance = o.factory.set({})

    -- 得到对外立场
    ---@param fac faction 对方阵营
    ---@return faction.stance 对外立场
    o.get_stance = function(fac)
        ---@type table<faction, faction.stance>
        local to_stance = o.stance()
        return to_stance[fac] or o.default_stance()
    end

    -- 设置对外立场
    ---@param fac faction 对方阵营
    ---@param stance faction.stance 对外立场
    o.set_stance = function(fac, stance)
        ---@type table<faction, faction.stance>
        local to_stance = o.stance()
        to_stance[fac] = stance
        o.stance.set(to_stance)
    end

    ---@param fac faction 对方阵营
    ---@return boolean 返回是否友好
    o.is_friendly = function(fac)
        if o == fac then
            return true
        end

        -- 是否是盟友
        if o.get_stance(fac) == "friendly" then
            return true
        end

        return false
    end

    ---@param fac faction 对方阵营
    ---@return boolean 返回是否中立
    o.is_neutral = function(fac)
        if o == fac then
            return false
        end

        -- 是否是中立
        if o.get_stance(fac) == "neutral" then
            return true
        end

        return false
    end

    ---@param fac faction 对方阵营
    ---@return boolean 返回是否敌对
    o.is_hostile  = function(fac)
        if o == fac then
            return false
        end

        -- 是否是敌人
        if o.get_stance(fac) == "hostile" then
            return true
        end

        return false
    end

    ---@return list<faction> 所有同盟阵营
    o.ally = function()
        -- 声明
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

    ---@return list<faction> 所有敌对阵营
    o.enemy = function()
        -- 声明
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

    ---设置同盟（对方不一定同盟）
    ---@param fac faction 对方阵营
    ---@return nil
    o.set_friendly = function(fac)
        if o == fac then
            return
        end

        -- 不重复
        if o.get_stance(fac) == "friendly" then
            return
        end

        o.set_stance(fac, "friendly")
    end

    ---设置敌对（对方不一定敌对）
    ---@param fac faction 对方阵营
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

    -- 结盟（双向）
    ---@param fac faction 对方阵营
    ---@return nil
    o.ally_with = function(fac)
        o.set_friendly(fac)
        fac.set_friendly(o)
    end

    -- 敌对（双向）
    ---@param fac faction 对方阵营
    ---@return nil
    o.hostile_with = function(fac)
        o.set_hostile(fac)
        fac.set_hostile(o)
    end

    ---设置中立
    ---@param fac faction 对方阵营
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
