---@type lib.metatablex
local metatable = require "lib.metatablex"
---@type framework.ui.apis
local apis = require ".apis"

---@class framework.ui
---@field apis framework.ui.apis UI callback API 表
---@field HANDLE_TO_OBJECT table<ui.handle, ui> 控件句柄到框架 UI 对象的映射
---@field anchor fun(args?: ui.anchor): ui.anchor 规范化锚点配置
---@field LAYER table<string, ui.handle> UI 分层句柄
local M = {}
package.loaded[...] = M

M.apis = apis

---@type table<ui.handle, ui>
M.HANDLE_TO_OBJECT = {}

---@alias ui.type
---| "void" -- 空节点
---| "text"
---| "image"
---| "progress_ring"
---| "slider" -- 滑条
---| "input"

---@alias ui.position
---| "left_top" -- 左上
---| "top_left" -- 上左
---| "center_top" -- 中上
---| "top_center"
---| "right_top"
---| "top_right" -- 上右
---| "center_left" -- 中左
---| "left_center"
---| "center" -- 中心
---| "center_right" -- 中右
---| "right_center"
---| "left_bottom" -- 左下
---| "bottom_left" -- 下左
---| "center_bottom" -- 中下
---| "bottom_center" -- 下中
---| "right_bottom"
---| "bottom_right" -- 下右

---@class ui.anchor
---@field point ui.position 当前 UI 锚点方位
---@field relative_point ui.position 目标锚点方位
---@field x number 横向偏移比例
---@field y number 纵向偏移比例
---@field relative_ui? ui 相对定位目标
---@param args ui.anchor 锚点配置
---@return ui.anchor anchor 规范化后的锚点配置
M.anchor = function(args)
    ---@class ui.anchor
    args = args or {}
    args.point = args.point or "center"
    args.relative_point = args.relative_point or "center"
    args.x = args.x or 0
    args.y = args.y or 0

    return metatable.with_tostring(args, function()
        local fields = { args.point, args.relative_point }
        if args.x and args.x ~= 0 then
            table.insert(fields, string.format("x=%.2f", args.x))
        end
        if args.y and args.y ~= 0 then
            table.insert(fields, string.format("y=%.2f", args.y))
        end
        if args.relative_ui then
            table.insert(fields, tostring(args.relative_ui))
        end
        local attrs = table.concat(fields, ",")
        return string.format("<ui.anchor %s>", attrs)
    end)
end

---@enum ui.layer
M.LAYER = {
    DEFAULT = nil, ---@type ui.handle 默认层
    WINDOW = nil, ---@type ui.handle 窗口层
    HUD = nil, ---@type ui.handle HUD 层
    SYSTEM = nil, ---@type ui.handle 系统层
    CINEMATIC = nil, ---@type ui.handle 演出层
}

local LAYER_NAMES = {
    DEFAULT = true,
    WINDOW = true,
    HUD = true,
    SYSTEM = true,
    CINEMATIC = true,
}

setmetatable(M.LAYER, {
    __index = function(layers, name)
        if not LAYER_NAMES[name] then
            return nil
        end

        local api = apis.CREATE({})
        assert(api.handle ~= nil, "framework.ui.LAYER requires runtime backend")
        local layer = api.handle
        rawset(layers, name, layer)
        return layer
    end,
})

require ".impl"
require ".object"
require ".frame"
require ".layout"

return M
