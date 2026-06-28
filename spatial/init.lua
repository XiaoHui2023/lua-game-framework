---@class framework.spatial
---@field settings framework.spatial.settings
---@field collision table
---@field create_body fun(args?: spatial.BodyOptions): spatial.Body
---@field setup_body fun(o: table, args?: spatial.BodyOptions): spatial.Body
---@field create_object fun(args?: spatial.ObjectOptions): spatial.Object
---@field setup_object fun(o: table, args?: spatial.ObjectOptions): spatial.Object
---@field create_group fun(args?: spatial.GroupOptions): spatial.Group
---@field create_world fun(args?: spatial.WorldOptions): spatial.World
---@field factory table
local M = {}
package.loaded[...] = M

M.settings = require ".settings"
M.collision = require ".collision"

require ".object"
require ".group"
require ".world"
M.factory = require ".factory"

return M
