---@type framework.ui.state
local state = require "framework.ui.state"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type framework.log
local log = require "framework.log"

local function bool_text(value)
    return value and "true" or "false"
end

local function number_text(value)
    return string.format("%.2f", tonumber(value) or 0)
end

local function call_or_default(func, default, ...)
    if type(func) ~= "function" then
        return default
    end
    local ok, a, b = pcall(func, ...)
    if not ok then
        return default
    end
    return a, b
end

local function table_or_empty(func)
    local value = call_or_default(func, nil)
    return type(value) == "table" and value or {}
end

---@param ui framework.ui
---@return string
local function get_ui_name(ui)
    local full_name = call_or_default(ui.factory.full_name, nil)
    if full_name ~= nil and full_name ~= "" then
        return tostring(full_name)
    end
    local name = call_or_default(ui.factory.name, nil)
    if name ~= nil and name ~= "" then
        return tostring(name)
    end
    return tostring(ui)
end

---@return framework.ui.layout.stats
local function create_stats()
    return {
        debug_enabled = state.DEBUG,
        total_count = 0,
        root_count = 0,
        visible_count = 0,
        hidden_count = 0,
        container_count = 0,
        content_sized_count = 0,
        zero_size_count = 0,
        max_depth = 0,
        total_area = 0,
        max_area = 0,
        largest_ui_name = "",
        by_type = {},
    }
end

---@return table<framework.ui, framework.ui[]>
local function build_children_by_parent()
    local children_by_parent = {}
    for _, ui in pairs(state.HANDLE_TO_OBJECT) do
        local parent_factory = call_or_default(ui.factory.parent, nil)
        local parent = parent_factory and parent_factory.owner or nil
        if parent ~= nil then
            local children = children_by_parent[parent]
            if children == nil then
                children = {}
                children_by_parent[parent] = children
            end
            children[#children + 1] = ui
        end
    end
    return children_by_parent
end

---@param root framework.ui|nil
---@return framework.ui[]
local function collect_roots(root)
    if root ~= nil then
        return { root }
    end

    local roots = {}
    for _, ui in pairs(state.HANDLE_TO_OBJECT) do
        local parent_factory = call_or_default(ui.factory.parent, nil)
        local parent = parent_factory and parent_factory.owner or nil
        local parent_handle = parent and parent.handle and call_or_default(parent.handle, nil) or nil
        if parent == nil or parent_handle == nil or state.HANDLE_TO_OBJECT[parent_handle] == nil then
            roots[#roots + 1] = ui
        end
    end
    return roots
end

---@param stats framework.ui.layout.stats
---@param ui framework.ui
---@param depth integer
local function add_stats(stats, ui, depth)
    local width, height = call_or_default(ui.visual_size, 0)
    width = width or 0
    height = height or 0

    stats.total_count = stats.total_count + 1
    stats.max_depth = math.max(stats.max_depth, depth)

    local ui_type = ui.type or "unknown"
    stats.by_type[ui_type] = (stats.by_type[ui_type] or 0) + 1
    if ui_type == "container" or ui.widgets ~= nil then
        stats.container_count = stats.container_count + 1
    end
    local size_spec = table_or_empty(ui.size_spec)
    if size_spec.width == "auto" or size_spec.height == "auto" then
        stats.content_sized_count = stats.content_sized_count + 1
    end

    local is_visible = call_or_default(ui.visible, false)
    if is_visible then
        stats.visible_count = stats.visible_count + 1
    else
        stats.hidden_count = stats.hidden_count + 1
    end

    if width == 0 or height == 0 then
        stats.zero_size_count = stats.zero_size_count + 1
    end

    local area = width * height
    stats.total_area = stats.total_area + area
    if area > stats.max_area then
        stats.max_area = area
        stats.largest_ui_name = get_ui_name(ui)
    end
end

---@param lines string[]
---@param ui framework.ui
---@param depth integer
local function add_line(lines, ui, depth)
    local width, height = call_or_default(ui.visual_size, 0)
    width = width or 0
    height = height or 0
    local visible = call_or_default(ui.visible, false)
    local layout_type = ui.layout and ui.layout.type and call_or_default(ui.layout.type, nil) or nil
    local measured = table_or_empty(ui.measured_size)
    local render_rect = table_or_empty(ui.render_rect)
    local prefix = string.rep("  ", depth)
    lines[#lines + 1] = string.format(
        "%s- %s type=%s measured=%sx%s render=%sx%s visible=%s layout=%s",
        prefix,
        get_ui_name(ui),
        tostring(ui.type or "unknown"),
        number_text(measured.width),
        number_text(measured.height),
        number_text(render_rect.width or width),
        number_text(render_rect.height or height),
        bool_text(visible),
        tostring(layout_type or "")
    )
end

---@param roots framework.ui[]
---@param children_by_parent table<framework.ui, framework.ui[]>
---@return framework.ui.layout.stats, string[]
local function inspect_tree(roots, children_by_parent)
    local stats = create_stats()
    local lines = {}
    local visited = {}

    local function visit(ui, depth)
        if visited[ui] then
            return
        end
        visited[ui] = true
        add_stats(stats, ui, depth)
        add_line(lines, ui, depth)
        local children = children_by_parent[ui] or {}
        for _, child in ipairs(children) do
            visit(child, depth + 1)
        end
    end

    stats.root_count = #roots
    for _, root in ipairs(roots) do
        visit(root, 0)
    end

    return stats, lines
end

-- Write UI diagnostics through the shared framework logger.
apis.WRITE_DEBUG_INFO(function(api)
    local level = api.level or "debug"
    local writer = log[level] or log.debug
    writer(api.message)
end)

-- Toggle framework-owned UI layout diagnostics.
apis.SET_DEBUG(function(api)
    state.DEBUG = api.enabled and true or false
    apis.WRITE_DEBUG_INFO({
        level = "info",
        message = "ui layout debug enabled=" .. bool_text(state.DEBUG),
    })
end)

-- Collect size and layout counters from the current UI object tree.
apis.GET_LAYOUT_STATS(function(api)
    local stats = inspect_tree(collect_roots(api.root), build_children_by_parent())
    api.stats = stats
end)

-- Build a readable UI layout tree and optionally send it to the runtime logger.
apis.DUMP_LAYOUT_TREE(function(api)
    if not state.DEBUG and not api.force then
        return
    end

    local stats, lines = inspect_tree(collect_roots(api.root), build_children_by_parent())
    api.stats = stats
    api.lines = lines

    if api.print == false then
        return
    end

    local summary = string.format(
        "ui layout stats total=%d roots=%d visible=%d hidden=%d zero_size=%d max_depth=%d total_area=%s max_area=%s largest=%s",
        stats.total_count,
        stats.root_count,
        stats.visible_count,
        stats.hidden_count,
        stats.zero_size_count,
        stats.max_depth,
        number_text(stats.total_area),
        number_text(stats.max_area),
        stats.largest_ui_name
    )
    apis.WRITE_DEBUG_INFO({ level = "info", message = summary })
    for _, line in ipairs(lines) do
        apis.WRITE_DEBUG_INFO({ level = "debug", message = line })
    end
end)

return true
