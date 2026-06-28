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
    if child.is_layout_managed then
        child.is_layout_managed.set(true)
    end
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
    local layout_children = {}
    local content_children = {}

    local function add_child(child, include_in_content)
        layout_children[#layout_children + 1] = child
        if include_in_content ~= false then
            content_children[#content_children + 1] = child
        end
    end

    if args.background.enable then
        local image_api = apis.CREATE_IMAGE({
            options = table.merge(args.background, {
                name = args.background.name or "background",
                parent = o.factory,
            }),
        })
        assert(image_api.ui ~= nil, "framework.ui.CREATE_SLOT requires CREATE_IMAGE result for background")
        local background = image_api.ui
        ---@cast background framework.ui.slot.background
        background.include_in_content = args.background.include_in_content ~= false
        o.background = background
        add_child(background, args.background.include_in_content)
    end

    if args.progress.enable then
        local progress_api = apis.CREATE_PROGRESS({
            options = table.merge(args.progress, {
                name = args.progress.name or "progress",
                parent = o.factory,
            }),
        })
        assert(progress_api.ui ~= nil, "framework.ui.CREATE_SLOT requires CREATE_PROGRESS result")
        local progress = progress_api.ui
        ---@cast progress framework.ui.slot.progress
        progress.include_in_content = args.progress.include_in_content ~= false
        o.progress = progress
        add_child(progress, args.progress.include_in_content)
    end

    if args.image.enable then
        local image_api = apis.CREATE_IMAGE({
            options = table.merge(args.image, {
                name = args.image.name or "image",
                parent = o.factory,
            }),
        })
        assert(image_api.ui ~= nil, "framework.ui.CREATE_SLOT requires CREATE_IMAGE result")
        local image = image_api.ui
        ---@cast image framework.ui.slot.image
        image.include_in_content = args.image.include_in_content ~= false
        o.image = image
        add_child(image, args.image.include_in_content)
    end

    if args.text.enable then
        local text_api = apis.CREATE_TEXT({
            options = table.merge(args.text, {
                name = args.text.name or "text",
                parent = o.factory,
            }),
        })
        assert(text_api.ui ~= nil, "framework.ui.CREATE_SLOT requires CREATE_TEXT result")
        local text = text_api.ui
        ---@cast text framework.ui.slot.text
        text.include_in_content = args.text.include_in_content ~= false
        o.text = text
        add_child(text, args.text.include_in_content)
    end

    o.content_size.compute(function()
        local max_width, max_height = 0, 0
        for _, child in ipairs(content_children) do
            local size = child.measured_size()
            max_width = math.max(max_width, size.width)
            max_height = math.max(max_height, size.height)
        end
        return { width = max_width, height = max_height }
    end)

    local function refresh_children()
        for _, child in ipairs(layout_children) do
            center_child(o, child)
        end
    end

    o.measured_size.on_change.add(refresh_children)
    o.pixel_position.on_change.add(refresh_children)
    refresh_children()

    api.ui = o
end)

return true
