---@class framework.skill
local M = require ".base"

---@type framework.skill.apis
local apis = require ".apis"

---@class skill.active.options: skill.options
---@field cooldown? number 字段说明
---@field max_cooldown? number 字段说明
---@field input_kind? skill.input_kind 字段说明
---@field active_effects? skill.active_effect[] 字段说明
---@field on_cast? fun(skill:skill.active, 字段说明

---@alias skill.input_kind
---| "none"
---| "unit" 点击单位
---| "point" 点击位置
---| "drag" 拖拽输入
---| "multi_click" 多次点击输入
---| "gesture" 轨迹或画图形输入
---| "custom" 业务自定义输入

---@class skill.cast_request
---@field kind? skill.input_kind 字段说明
---@field caster? unit 字段说明
---@field target_unit? unit 字段说明
---@field target_point? point 字段说明
---@field points? point[] 字段说明
---@field payload? table 字段说明
---@field engine_event? any 字段说明

M.REQUEST_CAST = apis.REQUEST_CAST
M.BEFORE_CAST = apis.BEFORE_CAST
M.AFTER_CAST = apis.AFTER_CAST

---@param request? skill.cast_request 参数说明
---@param default_kind skill.input_kind
---@return skill.cast_request
local function normalize_request(request, default_kind)
    request = request or {}
    request.kind = request.kind or default_kind
    return request
end

---@param args? skill.active.options 参数说明
---@return skill.active
M.create_active = function(args)
    args = args or {}
    args.cooldown = args.cooldown or 0
    args.max_cooldown = args.max_cooldown or args.cooldown or 0
    args.input_kind = args.input_kind or "none"

    ---@class skill.active: skill
    local o = M.new(args)
    o.set_class("skill.active")

    ---@type hook.set<number>
    o.cooldown = o.factory.set(args.cooldown)

    ---@type hook.set<skill.input_kind>
    o.input_kind = o.factory.set(args.input_kind)

    ---@type skill.stat
    o.max_cooldown = o.create_stat({
        kind = "cooldown",
        unit = "number",
        value = args.max_cooldown,
    })

    ---@type hook.add<skill.active_effect>
    o.active_effects = o.factory.add()

    ---@type hook.semaphore
    o.lock = o.factory.semaphore()

    ---@type hook.event
    o.on_cast = o.factory.event()

    ---@type hook.event
    o.on_cooldown_ready = o.factory.event()

    ---@type hook.event
    o.on_cooldown_start = o.factory.event()

    o.active_effects.wrap_add(function(effect)
        if type(effect.on_attach) == "function" then
            effect.on_attach(o)
        end
        o.delete.add(function()
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

    ---@return number
    o.get_max_cooldown = function()
        return o.max_cooldown.value()
    end

    ---@return boolean
    o.is_cooldown_ready = function()
        return o.cooldown() <= 0
    end

    ---@param value? number 参数说明
    o.start_cooldown = function(value)
        o.cooldown.set(value or o.get_max_cooldown())
    end

    o.refresh_cooldown = function()
        o.cooldown.set(0)
    end

    ---@param delta number 参数说明
    ---@return boolean 返回值
    o.reduce_cooldown = function(delta)
        if delta <= 0 then
            return false
        end
        o.cooldown.set(o.cooldown() - delta)
        return true
    end

    ---@param delta number 参数说明
    ---@return boolean 是否更新了冷却
    o.tick_cooldown = function(delta)
        return o.reduce_cooldown(delta)
    end

    ---@param request? skill.cast_request 参数说明
    ---@return skill.cast_request
    o.request_cast = function(request)
        request = normalize_request(request, o.input_kind())
        request.caster = request.caster or o.context().unit
        M.REQUEST_CAST({
            skill = o,
            request = request,
        })
        return request
    end

    ---@param request? skill.cast_request 参数说明
    ---@return boolean success 是否释放成功
    ---@return any result 主动效果或 on_cast 返回值
    o.cast = function(request)
        if o.lock.is_acquired() then
            return false, "locked"
        end

        if o.cooldown() > 0 then
            return false, "cooldown"
        end

        request = o.request_cast(request)

        local before = M.BEFORE_CAST({
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
        o.active_effects().for_each(function(effect)
            if type(effect.on_cast) == "function" then
                result = effect.on_cast(o, request) or result
            end
        end)

        o.on_cast(request, result)
        o.start_cooldown()

        M.AFTER_CAST({
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

    o.factory.register_hook_fields()

    return o
end

return M
