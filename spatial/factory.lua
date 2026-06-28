---@type framework.spatial
local spatial = require "framework.spatial"

local M = {}

---@param args? spatial.BodyOptions
---@return spatial.Body
function M.create(args)
    return spatial.create_body(args)
end

---@param o table
---@param args? spatial.BodyOptions
---@return spatial.Body
function M.setup(o, args)
    return spatial.setup_body(o, args)
end

setmetatable(M, {
    __call = function(_, args)
        return M.create(args)
    end,
})

return M
