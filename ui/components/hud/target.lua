---@class framework.ui.components.hud.target
local M = {}
require "framework.ui"
---@type framework.ui.apis
local ui_apis = require "framework.ui.apis"
---@type framework.ui.components.status.health_bar
local health_bar_prefab = require "framework.ui.components.status.health_bar"

M.DEFAULT_FRAME_NAME = "frame"
M.DEFAULT_BUFF_NODE_NAME = "buff_node"
M.DEFAULT_HEALTH_NODE_NAME = "health_node"
M.DEFAULT_NAME_NODE_NAME = "name_node"
M.DEFAULT_NAME_TEXT_NAME = "name_text"

---@class framework.ui.components.hud.target.options
---@field frame_name? string
---@field buff_node_name? string
---@field health_node_name? string
---@field name_node_name? string
---@field name_text_name? string

---@param args? framework.ui.components.hud.target.options
---@return framework.ui.hud.target
M.create = function(args)
    args = args or {}
    args.frame_name = args.frame_name or M.DEFAULT_FRAME_NAME
    args.buff_node_name = args.buff_node_name or M.DEFAULT_BUFF_NODE_NAME
    args.health_node_name = args.health_node_name or M.DEFAULT_HEALTH_NODE_NAME
    args.name_node_name = args.name_node_name or M.DEFAULT_NAME_NODE_NAME
    args.name_text_name = args.name_text_name or M.DEFAULT_NAME_TEXT_NAME

    local frame_api = ui_apis.CREATE_CONTAINER({
        options = {
            name = args.frame_name,
            layout = {
                type = "stack",
                direction = "vertical",
                gap = 4,
            },
            show = false,
        },
    })
    ---@class framework.ui.hud.target : framework.ui.container
    local o = frame_api.ui

    local name_node_api = ui_apis.CREATE_CONTAINER({
        options = {
            name = args.name_node_name,
            layout = { type = "overlay" },
            show = true,
        },
    })
    o.name_node = name_node_api.ui

    local health_node_api = ui_apis.CREATE_CONTAINER({
        options = {
            name = args.health_node_name,
            layout = { type = "overlay" },
            show = true,
        },
    })
    o.health_node = health_node_api.ui

    local buff_node_api = ui_apis.CREATE_CONTAINER({
        options = {
            name = args.buff_node_name,
            layout = {
                type = "stack",
                direction = "horizontal",
                gap = 4,
            },
            show = true,
        },
    })
    o.buff_node = buff_node_api.ui

    local name_text_api = ui_apis.CREATE_TEXT({
        options = {
            name = args.name_text_name,
            size = { width = "auto", height = "auto" },
            show = true,
        },
    })
    o.name_text = name_text_api.ui

    o.health_bar = health_bar_prefab.create({
        show = true,
    })

    o.factory.add_children({
        o.name_node.factory,
        o.health_node.factory,
        o.buff_node.factory,
    })
    o.name_node.factory.add_child(o.name_text.factory)
    o.health_node.factory.add_child(o.health_bar.factory)

    return o
end

return M
