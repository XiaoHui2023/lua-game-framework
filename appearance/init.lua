---@class framework.appearance
local M = {}
package.loaded[...] = M

---@class framework.appearance.data
---@field dt number
---@field changes table<string, any>

---@class framework.appearance.result
---@field data framework.appearance.data
---@field changes table<string, any>

M.KIND = {
    ANIMATION = "animation",
    COLOR = "color",
    OUTLINE = "outline",
    OVERLAY = "overlay",
    FLIP_X = "flip.x",
    FLIP_Y = "flip.y",
    FLIP_Z = "flip.z",
    TURN_X = "turn.x",
    TURN_Y = "turn.y",
    TURN_Z = "turn.z",
    TURN_HEAD = "turn.head",
    TURN_BODY = "turn.body",
    TURN_FOOT = "turn.foot",
}

---@param args? table 表现数据配置
---@return framework.appearance.data
function M.data(args)
    args = args or {}
    return {
        dt = args.dt or 0,
        changes = args.changes or {},
    }
end

---@param data framework.appearance.data
---@param kind string
---@param value any
function M.set_change(data, kind, value)
    data.changes[kind] = value
end

---@param data framework.appearance.data
---@return framework.appearance.result
function M.resolve(data)
    return {
        data = data,
        changes = data.changes,
    }
end

---@class framework.appearance
require "framework.appearance.modifier"
require "framework.appearance.renderer"

return M
