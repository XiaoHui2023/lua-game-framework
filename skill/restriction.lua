---@class framework.skill
local M = require "framework.skill"

---@class skill.restriction.options
---@field key? string
---@field description? string
---@field visible? boolean
---@field check? fun(skill:skill.active, request:skill.cast_request):boolean,string?
---@field consume? fun(skill:skill.active, request:skill.cast_request)

---@param args skill.restriction.options
---@return skill.restriction
function M.create_restriction(args)
    args = args or {}
    ---@class skill.restriction
    local o = {
        key = args.key or "restriction",
        description = args.description or "",
        visible = args.visible ~= false,
    }

    function o.check(skill, request)
        if type(args.check) == "function" then
            return args.check(skill, request)
        end
        return true
    end

    function o.consume(skill, request)
        if type(args.consume) == "function" then
            args.consume(skill, request)
        end
    end

    return o
end

---@param skill skill.active
---@param request skill.cast_request
---@return boolean
---@return string?
function M.check_restrictions(skill, request)
    local restrictions = skill.usage_restrictions and skill.usage_restrictions() or {}
    local failed_reason = nil
    restrictions.for_each(function(restriction, context)
        local ok, reason = restriction.check(skill, request)
        if not ok then
            failed_reason = reason or restriction.key
            context.stop()
        end
    end)
    return failed_reason == nil, failed_reason
end

---@param skill skill.active
---@param request skill.cast_request
function M.consume_restrictions(skill, request)
    local restrictions = skill.usage_restrictions and skill.usage_restrictions() or {}
    restrictions.for_each(function(restriction)
        restriction.consume(skill, request)
    end)
end

---@return skill.restriction
function M.create_cooldown_restriction()
    return M.create_restriction({
        key = "cooldown",
        description = "冷却时间",
        check = function(skill)
            return skill.is_cooldown_ready(), "cooldown"
        end,
        consume = function(skill)
            skill.start_cooldown()
        end,
    })
end

return M
