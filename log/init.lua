---@class framework.log.backend
---@field debug? fun(...) 写入 debug 级别日志
---@field info? fun(...) 写入 info 级别日志
---@field warn? fun(...) 写入 warn 级别日志
---@field error? fun(...) 写入 error 级别日志

---@class framework.log
---@field set_backend fun(next_backend: framework.log.backend) 设置日志输出后端
---@field debug fun(...) 写入 debug 级别日志
---@field info fun(...) 写入 info 级别日志
---@field warn fun(...) 写入 warn 级别日志
---@field error fun(...) 写入 error 级别日志
local M = {}

---@type framework.log.backend
local backend = {
    debug = function(...)
        print(...)
    end,
    info = function(...)
        print(...)
    end,
    warn = function(...)
        print(...)
    end,
    error = function(...)
        error(tostring((...)), 2)
    end,
}

---@param next_backend framework.log.backend 新的日志输出后端；未提供的级别保持原后端
function M.set_backend(next_backend)
    assert(type(next_backend) == "table", "framework.log backend must be a table")

    for _, level in ipairs({ "debug", "info", "warn", "error" }) do
        local writer = next_backend[level]
        if writer ~= nil then
            assert(type(writer) == "function", "framework.log backend." .. level .. " must be a function")
            backend[level] = writer
        end
    end
end

function M.debug(...)
    return backend.debug(...)
end

function M.info(...)
    return backend.info(...)
end

function M.warn(...)
    return backend.warn(...)
end

function M.error(...)
    return backend.error(...)
end

return M
