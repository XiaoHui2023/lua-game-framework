---@type framework.ui.state
local state = require "framework.ui.state"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

local attach_common = require "framework.ui.impl.core.common"
local attach_visible = require "framework.ui.impl.core.visible"
local attach_size = require "framework.ui.impl.core.size"
local attach_position = require "framework.ui.impl.core.position"
local attach_event = require "framework.ui.impl.core.event"
local attach_anchor = require "framework.ui.impl.core.anchor"
local attach_drag = require "framework.ui.impl.core.drag"
local attach_snap = require "framework.ui.impl.core.snap"
local attach_text = require "framework.ui.impl.core.text"

-- 注册 UI 基础响应式逻辑；父子关系只通过 factory 父级事件同步到运行时后端。
apis.SETUP_REACTIVE_LOGIC(function(api)
    ---@type framework.ui
    local ui = api.ui
    local options = api.options or {}

    ui.factory.on_set_parent.add(function(parent)
        apis.SET_PARENT({
            ui = ui,
            parent_handle = parent and parent.handle() or ui.layer,
        })
    end)

    attach_common(ui)
    attach_text(ui, options)
    attach_visible(ui, options)
    attach_size(ui, options)
    attach_position(ui, options)
    attach_event(ui, options)
    attach_anchor(ui, options)
    attach_drag(ui, options)
    attach_snap(ui)

    ui.factory.set_parent(options.parent)

    ui.delete.add(function()
        ui.factory.set_parent(nil)
        apis.DELETE({ handle = ui.handle() })
    end)

    state.HANDLE_TO_OBJECT[ui.handle()] = ui
    ui.delete.add(function()
        state.HANDLE_TO_OBJECT[ui.handle()] = nil
    end)

    apis.OBJECT_CREATED({ ui = ui, options = options })
    apis.ON_CREATE({ ui = ui })
end)

return true
