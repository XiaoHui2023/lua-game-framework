local pipeline = require "core.pipeline"
---@type utils.hook
local hook = require "utils.hook"

---@class core.combat.context 打击上下文
---@field damage? number 伤害
---@field has_cc boolean 是否有控制效果

---@class core.combat.result 打击结果
---@field damage number 最终伤害
---@field hit boolean 是否命中
---@field has_damage boolean 是否有伤害效果
---@field has_cc boolean 是否有控制效果

-- 创建攻击方修改器组
---@return core.combat.attacker
local function create_attacker_modifiers()
    ---@class core.combat.attacker
    local o = {}

    ---@type core.pipeline 固定伤害
    o.fixed = pipeline("first")

    ---@type core.pipeline 伤害加法
    o.flat = pipeline("chain")

    ---@type core.pipeline 伤害乘法
    o.percentage = pipeline("chain")

    return o
end

-- 创建防守方修改器组
---@return core.combat.defender
local function create_defender_modifiers()
    ---@class core.combat.defender
    local o = {}

    ---@type core.pipeline 闪避判定
    o.evasion = pipeline("or")

    ---@type core.pipeline 固定伤害
    o.fixed = pipeline("first")

    ---@type core.pipeline 伤害乘法
    o.percentage = pipeline("chain")

    ---@type core.pipeline 伤害加法
    o.flat = pipeline("chain")

    ---@type core.pipeline 最终判定
    o.final = pipeline("or")

    ---@type core.pipeline 伤害免疫判定
    o.damage_immunity = pipeline("or")

    ---@type core.pipeline 控制免疫判定
    o.cc_immunity = pipeline("or")

    return o
end

---@class core.combat.options
---@field attacker core.combat.attacker 攻击方修改器组
---@field defender core.combat.defender 防守方修改器组
---@field context core.combat.context 打击上下文

-- 打击
---@param args core.combat.options 选项
---@return core.combat.result 打击结果
local function combat(args)
    local context = args.context
    local attacker = args.attacker
    local defender = args.defender

    -- 默认值
    context.damage = context.damage or 0

    ---@type number 最终伤害
    local damage = 0
    ---@type boolean 是否命中
    local hit = false
    ---@type boolean 是否免疫伤害
    local damage_immune = false
    ---@type boolean 是否免疫控制
    local cc_immune = false
    ---@type boolean 是否能继续计算伤害
    local can_damage = true
    ---@type boolean 是否能继续计算控制
    local can_cc = context.has_cc

    -- 打包结果
    ---@return core.combat.result 打击结果
    local function pack_result()
        return {
            damage = (damage > 0 and damage) or 0,
            hit = hit,
            has_cc = context.has_cc and not cc_immune,
            has_damage = (damage_immune and false) or (damage > 0 and true) or false,
        }
    end

    -- 防守方闪避判定
    hit = defender.evasion.run(context)
    if not hit then
        return pack_result()
    end

    -- 防守方伤害免疫判定
    if can_damage then
        damage_immune = defender.damage_immunity.run(context)
        can_damage = not damage_immune
    end

    -- 进攻方固定伤害设置
    if can_damage then
        local fixed_damage = attacker.fixed.run(context)
        if fixed_damage ~= nil then
            damage = fixed_damage
            can_damage = false
        end
    end

    -- 防守方固定伤害设置
    if can_damage then
        local fixed_damage = defender.fixed.run(context)
        if fixed_damage ~= nil then
            damage = fixed_damage
            can_damage = false
        end
    end

    if can_damage then
        -- 进攻方伤害加法
        damage = attacker.flat.run(context,damage)
        -- 进攻方伤害乘法
        damage = attacker.percentage.run(context,damage)
        -- 防守方伤害乘法
        damage = defender.percentage.run(context,damage)
        -- 防守方伤害加法
        damage = defender.flat.run(context,damage)
    end

    -- 防守方最终判定
    if can_damage then
        damage_immune = defender.final.run(context,damage)
        can_damage = not damage_immune
    end

    if can_cc then
        -- 防守方控制免疫判定
        cc_immune = defender.cc_immunity.run(context)
    end

    return pack_result()
end

-- 创建打击系统
---@return core.combat
return function ()
    ---@class core.combat: hook.factory
    local o = hook.factory()
    o.set_class("core.combat")

    ---@type core.combat.attacker
    o.attacker = create_attacker_modifiers()
    ---@type core.combat.defender
    o.defender = create_defender_modifiers()
    o.run = combat

    -- 绑定删除
    o.delete.mount(o.attacker.fixed.delete)
    o.delete.mount(o.attacker.flat.delete)
    o.delete.mount(o.attacker.percentage.delete)
    o.delete.mount(o.defender.evasion.delete)
    o.delete.mount(o.defender.fixed.delete)
    o.delete.mount(o.defender.percentage.delete)
    o.delete.mount(o.defender.flat.delete)
    o.delete.mount(o.defender.final.delete)
    o.delete.mount(o.defender.damage_immunity.delete)
    o.delete.mount(o.defender.cc_immunity.delete)

    -- ()
    metatable.callable(o, o.run)

    return o
end