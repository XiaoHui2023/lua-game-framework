---@type lib.tablex
local table = require "lib.tablex"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
local length = require "framework.ui.impl.core.length"

local function child_constraints(slot)
    local size = slot.measured_size()
    return {
        min_width = 0,
        max_width = size.width,
        min_height = 0,
        max_height = size.height,
    }
end

local function center_child(slot, child)
    local position = slot.pixel_position()
    local size = child.measured_size()
    child.constraints.set(child_constraints(slot))
    child.pixel_position.set({ x = position.x, y = position.y })
    child.layout_rect.set(length.rect(position.x, position.y, size.width, size.height))
end

---@param api framework.ui.api.CreateSlot
apis.CREATE_SLOT(function(api)
    local args = table.deep_merge(api.options or {}, api.options_extra)
    args = args or {}
    args.progress = args.progress or {}
    args.image = args.image or {}
    args.background = args.background or {}
    args.text = args.text or {}
    args.image.enable = args.image.enable or false
    args.background.enable = args.background.enable or false
    args.progress.enable = args.progress.enable or false
    args.text.enable = args.text.enable or false
    args.background.show = (args.background.show == nil) and true or args.background.show
    args.progress.show = (args.progress.show == nil) and true or args.progress.show
    args.image.show = (args.image.show == nil) and true or args.image.show
    args.text.show = (args.text.show == nil) and true or args.text.show

    local void_api = apis.CREATE_VOID({ options = args })
    assert(void_api.ui ~= nil, "framework.ui.CREATE_SLOT requires CREATE_VOID result")
    ---@type framework.ui.slot
    local o = void_api.ui

    if args.background.enable then
        local image_api = apis.CREATE_IMAGE({
            options = table.merge(args.background, {
                name = args.background.name or "background",
                parent = o.factory,
            }),
        })
        o.background = image_api.ui
        o.background.include_in_content = args.background.include_in_content ~= false
    end

    if args.progress.enable then
        local progress_api = apis.CREATE_PROGRESS({
            options = table.merge(args.progress, {
                name = args.progress.name or "progress",
                parent = o.factory,
            }),
        })
        o.progress = progress_api.ui
        o.progress.include_in_content = args.progress.include_in_content ~= false
    end

    if args.image.enable then
        local image_api = apis.CREATE_IMAGE({
            options = table.merge(args.image, {
                name = args.image.name or "image",
                parent = o.factory,
            }),
        })
        o.image = image_api.ui
        o.image.include_in_content = args.image.include_in_content ~= false
    end

    if args.text.enable then
        local text_api = apis.CREATE_TEXT({
            options = table.merge(args.text, {
                name = args.text.name or "text",
                parent = o.factory,
            }),
        })
        o.text = text_api.ui
        o.text.include_in_content = args.text.include_in_content ~= false
    end

    o.content_size.compute(function()
        local max_width, max_height = 0, 0
        for _, child in ipairs({ o.background, o.progress, o.image, o.text }) do
            if child and child.include_in_content ~= false then
                local size = child.measured_size()
                max_width = math.max(max_width, size.width)
                max_height = math.max(max_height, size.height)
            end
        end
        return { width = max_width, height = max_height }
    end)

    local function refresh_children()
        for _, child in ipairs({ o.background, o.progress, o.image, o.text }) do
            if child then
                center_child(o, child)
            end
        end
    end

    o.measured_size.on_change.add(refresh_children)
    o.pixel_position.on_change.add(refresh_children)
    refresh_children()

    api.ui = o
end)

return true