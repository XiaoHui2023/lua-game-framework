---@class framework.log.backend
---@field debug? fun(...) 输出调试日志，可选
---@field info? fun(...) 输出普通日志，可选
---@field warn? fun(...) 输出警告日志，可选
---@field error? fun(...) 输出错误日志，可选

---@class framework.log
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

---@param next_backend framework.log.backend
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
