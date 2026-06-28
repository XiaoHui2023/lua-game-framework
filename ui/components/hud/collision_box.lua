---@class framework.ui.components.hud.collision_box
local M = {}
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"

M.DEFAULT_IMAGE = nil
M.DEFAULT_PADDING = 0

---@class framework.ui.hud.collision_box.options : framework.ui.object_config
---@field image? any
---@field padding? number

---@param args? framework.ui.hud.collision_box.options
---@return framework.ui.hud.collision_box
M.create = function(args)
    args = args or {}
    args.image = args.image or M.DEFAULT_IMAGE
    args.size = args.size or { width = "auto", height = "auto" }

    local image_api = ui_apis.CREATE_IMAGE({ options = args })
    ---@class framework.ui.hud.collision_box : framework.ui.image
    local o = image_api.ui

    o.factory.ref_field("target_ui", nil)
    o.factory.ref_field("padding", args.padding or M.DEFAULT_PADDING)

    o.target_ui.on_change.add(function(target_ui)
        if target_ui then
            o.anchor_center(target_ui)
            o.show.set(true)
        else
            o.show.set(false)
        end
    end)

    o.content_size.compute(function()
        local target_ui = o.target_ui()
        if not target_ui then
            return { width = 0, height = 0 }
        end
        local target_size = target_ui.measured_size()
        local padding = o.padding()
        return {
            width = target_size.width + padding * 2,
            height = target_size.height + padding * 2,
        }
    end)

    return o
end

return M
