local M = {}

local AUTO = "auto"

local function copy_rect(rect)
    return {
        x = rect.x or 0,
        y = rect.y or 0,
        width = rect.width or 0,
        height = rect.height or 0,
    }
end

function M.px(value)
    return value or 0
end

function M.percent(value)
    return { percent = value or 0 }
end

function M.content()
    return { content = true }
end

function M.auto()
    return AUTO
end

function M.is_auto(value)
    return value == nil or value == AUTO or (type(value) == "table" and value.content == true)
end

function M.resolve(value, basis, content)
    if type(value) == "number" then
        return value
    end
    if type(value) == "table" and value.percent ~= nil then
        return basis * value.percent
    end
    if M.is_auto(value) then
        return content or 0
    end
    return 0
end

function M.normalize_constraints(value)
    value = value or {}
    return {
        min_width = value.min_width or 0,
        max_width = value.max_width or 0,
        min_height = value.min_height or 0,
        max_height = value.max_height or 0,
    }
end

function M.normalize_size_spec(value)
    value = value or {}
    return {
        width = value.width or AUTO,
        height = value.height or AUTO,
        min_width = value.min_width,
        min_height = value.min_height,
        max_width = value.max_width,
        max_height = value.max_height,
        aspect_ratio = value.aspect_ratio,
    }
end

function M.normalize_padding(value)
    if type(value) == "number" then
        return {
            left = value,
            right = value,
            top = value,
            bottom = value,
        }
    end
    value = value or {}
    return {
        left = value.left or value.x or 0,
        right = value.right or value.x or 0,
        top = value.top or value.y or 0,
        bottom = value.bottom or value.y or 0,
    }
end

function M.clamp(value, min_value, max_value)
    if min_value and value < min_value then
        value = min_value
    end
    if max_value and max_value > 0 and value > max_value then
        value = max_value
    end
    return value
end

function M.resolve_size(spec, constraints, content_size)
    spec = M.normalize_size_spec(spec)
    constraints = M.normalize_constraints(constraints)
    content_size = content_size or {}

    local width = M.resolve(spec.width, constraints.max_width, content_size.width)
    local height = M.resolve(spec.height, constraints.max_height, content_size.height)

    if spec.aspect_ratio and spec.aspect_ratio > 0 then
        if M.is_auto(spec.width) and not M.is_auto(spec.height) then
            width = height * spec.aspect_ratio
        elseif M.is_auto(spec.height) and not M.is_auto(spec.width) then
            height = width / spec.aspect_ratio
        end
    end

    width = M.clamp(width, spec.min_width or constraints.min_width, spec.max_width or constraints.max_width)
    height = M.clamp(height, spec.min_height or constraints.min_height, spec.max_height or constraints.max_height)

    return {
        width = math.floor(width + 0.5),
        height = math.floor(height + 0.5),
    }
end

function M.rect(x, y, width, height)
    return {
        x = x or 0,
        y = y or 0,
        width = width or 0,
        height = height or 0,
    }
end

function M.same_size(a, b)
    return b and a.width == b.width and a.height == b.height
end

function M.same_rect(a, b)
    return b and a.x == b.x and a.y == b.y and a.width == b.width and a.height == b.height
end

function M.copy_rect(rect)
    return copy_rect(rect or {})
end

return M
