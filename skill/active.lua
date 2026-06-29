---@class framework.skill
local M = require "framework.skill"
---@type framework.skill.apis
local apis = require ".apis"
---@class skill.active.options: skill.options
---@field cooldown? number 当前冷却时间
---@field max_cooldown? number 最大冷却时间
---@field input_kind? skill.input_kind 技能输入类型
---@field shortcut? event.key|string 快捷键
---@field active_effects? skill.active_effect[] 主动技能效果列表
---@field usage_restrictions? skill.restriction[] 通用使用限制列表，冷却也是其中一种派生限制
---@field action_tree? table 释放后运行的动作状态树
---@field action_name? string 动作运行名称
---@field on_cast? fun(skill:skill.active, request:skill.cast_request):any 主动释放回调
---@alias skill.input_kind
---| "none"
---| "unit" 点击单位
---| "point" 点击位置
---| "drag" 拖拽输入
---| "multi_click" 多次点击输入
---| "gesture" 轨迹或画图形输入
---| "custom" 业务自定义输入
---@class skill.cast_request
---@field kind? skill.input_kind 本次释放请求的输入类型
---@field caster? unit 释放者单位
---@field target_unit? unit 目标单位
---@field target_point? point 目标位置
---@field points? point[] 多点输入位置列表
---@field payload? table 业务自定义数据
---@field engine_event? any 底层引擎事件对象
---@param request? skill.cast_request 释放请求，省略时创建默认请求
---@param default_kind skill.input_kind
---@return skill.cast_request
local function normalize_request(request, default_kind)
    request = request or {}
    request.kind = request.kind or default_kind
    return request
end
local restriction = require ".restriction"
local action = require "framework.action"
local event_apis = require "framework.event.apis"
---@param args? skill.active.options 主动技能配置
---@return skill.active
M.create_active = function(args)
    args = args or {}
    args.cooldown = args.cooldown or 0
    args.max_cooldown = args.max_cooldown or args.cooldown or 0
    args.input_kind = args.input_kind or "none"
---@class skill.active: skill
    local o = M.new(args)
    o.factory.set_class("skill.active")
---@type hook.set<number>
    o.factory.ref_field("cooldown", args.cooldown)
---@type hook.set<skill.input_kind>
    o.factory.ref_field("input_kind", args.input_kind)
---@type hook.set<string>
    o.factory.ref_field("shortcut", args.shortcut)
---@type skill.stat
    o.max_cooldown = o.create_stat({
        kind = "cooldown",
        unit = "number",
        value = args.max_cooldown,
    })
---@type hook.add<skill.active_effect>
    o.factory.collection_field("active_effects")
---@type hook.add<skill.restriction>
    o.factory.collection_field("usage_restrictions")
---@type hook.semaphore
    o.factory.field("lock").semaphore()
---@type hook.event
    o.factory.event_field("on_cast")
---@type hook.event
    o.factory.event_field("on_cooldown_ready")
---@type hook.event
    o.factory.event_field("on_cooldown_start")

    o.active_effects.wrap_add(function(effect)
        if type(effect.on_attach) == "function" then
            effect.on_attach(o)
        end
        o.factory.delete.add(function()
            if type(effect.on_detach) == "function" then
                effect.on_detach(o)
            end
        end)
        return effect
    end)

    if args.active_effects ~= nil then
        for _, effect in ipairs(args.active_effects) do
            o.active_effects.add(effect)
        end
    end
    if args.max_cooldown > 0 then
        o.usage_restrictions.add(restriction.create_cooldown_restriction())
    end
    if args.usage_restrictions ~= nil then
        for _, item in ipairs(args.usage_restrictions) do
            o.usage_restrictions.add(item)
        end
    end
---@return number
    o.get_max_cooldown = function()
        return o.max_cooldown.value()
    end
---@return boolean
    o.is_cooldown_ready = function()
        return o.cooldown() <= 0
    end
---@param value? number 指定冷却时间，省略时使用最大冷却
    o.start_cooldown = function(value)
        o.cooldown.set(value or o.get_max_cooldown())
    end
    o.refresh_cooldown = function()
        o.cooldown.set(0)
    end
---@param delta number 本帧经过的时间
---@return boolean success 是否更新了冷却
    o.reduce_cooldown = function(delta)
        if delta <= 0 then
            return false
        end
        o.cooldown.set(o.cooldown() - delta)
        return true
    end
---@param delta number 本帧经过的时间
---@return boolean success 是否更新了冷却
    o.tick_cooldown = function(delta)
        return o.reduce_cooldown(delta)
    end
---@param request? skill.cast_request 释放请求
---@return skill.cast_request
    o.request_cast = function(request)
        request = normalize_request(request, o.input_kind())
        request.caster = request.caster or o.context().unit
        apis.REQUEST_CAST({
            skill = o,
            request = request,
        })
        return request
    end
---@param request? skill.cast_request 释放请求
---@return boolean success 是否释放成功
---@return any result 主动效果或 on_cast 结果
    o.cast = function(request)
        if o.lock.is_acquired() then
            return false, "locked"
        end

        request = o.request_cast(request)

        local allowed, reason = restriction.check_restrictions(o, request)
        if not allowed then
            return false, reason or "restricted"
        end

        local before = apis.BEFORE_CAST({
            skill = o,
            request = request,
            cancelled = false,
        })
        if before.cancelled then
            return false, before.reason or "cancelled"
        end

        local result = nil
        if type(args.on_cast) == "function" then
            result = args.on_cast(o, request)
        end
        if args.action_tree ~= nil then
            result = action.run({
                name = args.action_name or o.display_name(),
                owner = o,
                source = request.caster or o.context().unit,
                skill = o,
                weapon = o.context().weapon,
                request = request,
                tree = args.action_tree,
            }) or result
        end
        o.active_effects().for_each(function(effect)
            if type(effect.on_cast) == "function" then
                result = effect.on_cast(o, request) or result
            end
        end)

        o.on_cast(request, result)
        restriction.consume_restrictions(o, request)

        apis.AFTER_CAST({
            skill = o,
            request = request,
            result = result,
        })

        return true, result
    end

    o.cooldown.wrap_set(function(value)
        local max_cooldown = o.get_max_cooldown()
        value = (value < 0 and 0) or value
        value = (value > max_cooldown and max_cooldown) or value
        return value
    end)
    o.cooldown.on_change.add(function(value, old_value)
        old_value = old_value or value
        if old_value == 0 and value > 0 then
            o.on_cooldown_start()
        elseif old_value > 0 and value == 0 then
            o.on_cooldown_ready()
        end
    end)

    o.factory.delete.add(event_apis.ON_UPDATE(function(api)
        o.tick_cooldown(api.delta or api.dt or action.DEFAULT_UPDATE_DELTA)
    end))

    return o
end

return M
