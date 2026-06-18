---@type framework.ui.apis
local apis = require "framework.ui.apis"

local attach_base = require "framework.ui.impl.object.base"
local attach_visible = require "framework.ui.impl.object.visible"
local attach_size = require "framework.ui.impl.object.size"
local attach_position = require "framework.ui.impl.object.position"
local attach_event = require "framework.ui.impl.object.event"
local attach_anchor = require "framework.ui.impl.object.anchor"
local attach_drag = require "framework.ui.impl.object.drag"
local attach_snap = require "framework.ui.impl.object.snap"

-- Registers the default framework behavior set for each UI object.
apis.OBJECT_CREATED(function(api)
    local ui = api.ui
    local options = api.options or {}

    attach_base(ui, options)
    attach_visible(ui, options)
    attach_size(ui, options)
    attach_position(ui, options)
    attach_event(ui, options)
    attach_anchor(ui, options)
    attach_drag(ui, options)
    attach_snap(ui, options)
end)
