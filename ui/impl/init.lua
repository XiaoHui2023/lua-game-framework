require "framework.ui.impl.create_anchor"
require "framework.ui.impl.object"
require "framework.ui.impl.mouse"

---@type framework.ui.state
local state = require "framework.ui.state"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

local attach_common = require "framework.ui.impl.common"
local attach_visible = require "framework.ui.impl.visible"
local attach_size = require "framework.ui.impl.size"
local attach_position = require "framework.ui.impl.position"
local attach_event = require "framework.ui.impl.event"
local attach_anchor = require "framework.ui.impl.anchor"
local attach_drag = require "framework.ui.impl.drag"
local attach_snap = require "framework.ui.impl.snap"
local attach_text = require "framework.ui.impl.text"

apis.SETUP_REACTIVE_FIELDS(function(api)
    ---@type framework.ui
    local ui = api.ui
    local options = api.options or {}

    ui.factory.parent.set(options.parent)

    local parent_handle = options.parent and options.parent.handle() or options.layer
    local create_api = apis.CREATE({
        type = options.type,
        parent_handle = parent_handle,
    })
    assert(create_api.handle ~= nil, "framework.ui.create requires runtime backend")
    ui.factory.handle.set(create_api.handle)

    ui.type = options.type
    ui.layer = options.layer

    ui.factory.priority.set(options.priority)
    ui.factory.alpha.set(options.alpha)
    ui.factory.image.set(options.image)
    ui.factory.progress.set(options.progress)
    ui.factory.rotation.set(options.rotation)
    ui.factory.color.set(options.color)
    ui.factory.children.add({
        prevent_duplicate = true,
    })
end)

apis.SETUP_REACTIVE_LOGIC(function(api)
    ---@type framework.ui
    local ui = api.ui
    local options = api.options or {}
    local child_removers = {}

    ---@param child framework.ui
    ui.attach_child = function(child)
        if not child_removers[child] then
            child_removers[child] = ui.children.add(child)
        end
    end

    ---@param child framework.ui
    ui.detach_child = function(child)
        local remove_child = child_removers[child]
        if remove_child then
            remove_child()
            child_removers[child] = nil
        end
    end

    ---@param parent framework.ui?
    ui.set_parent = function(parent)
        local old_parent = ui.parent()
        if old_parent == parent then
            return
        end

        if old_parent and old_parent.remove_child then
            old_parent.remove_child(ui)
        elseif old_parent and old_parent.detach_child then
            old_parent.detach_child(ui)
        end

        ui.parent.set(parent)
        apis.SET_PARENT({
            ui = ui,
            parent_handle = parent and parent.handle() or ui.layer,
        })

        if parent then
            if parent.attach_child then
                parent.attach_child(ui)
            else
                parent.children.add(ui)
            end
        end
    end

    local function attach_to_parent(parent)
        if not parent then
            return
        end

        if parent.attach_child then
            parent.attach_child(ui)
        else
            parent.children.add(ui)
        end
    end

    local function detach_from_parent()
        local parent = ui.parent()
        if parent and parent.remove_child then
            parent.remove_child(ui)
        elseif parent and parent.detach_child then
            parent.detach_child(ui)
        end
        ui.parent.set(nil)
    end

    attach_common(ui)
    attach_text(ui, options)
    attach_visible(ui, options)
    attach_size(ui, options)
    attach_position(ui, options)
    attach_event(ui, options)
    attach_anchor(ui, options)
    attach_drag(ui, options)
    attach_snap(ui)

    attach_to_parent(options.parent)

    ui.delete.add(function()
        detach_from_parent()
        apis.DELETE({ handle = ui.handle() })
    end)

    state.HANDLE_TO_OBJECT[ui.handle()] = ui
    ui.delete.add(function()
        state.HANDLE_TO_OBJECT[ui.handle()] = nil
    end)

    apis.OBJECT_CREATED({ ui = ui, options = options })
    apis.ON_CREATE({ ui = ui })
end)
