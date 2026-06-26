require "framework.ui.types"

---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o framework.ui
---@param args framework.ui.object_config
return function(o, args)
    local function create_anchor(anchor)
        local api = apis.CREATE_ANCHOR({ anchor = anchor })
        assert(api.anchor ~= nil, "framework.ui.anchor impl requires CREATE_ANCHOR result")
        return api.anchor
    end

    args.anchor = args.anchor or create_anchor()

    ---@type framework.ui
    o = o
    o.factory.ref_field("anchor", args.anchor)

    ---@param relative_ui framework.ui
    ---@param anchor framework.ui.anchor
    ---@param point framework.ui.position
    ---@param relative_point framework.ui.position
    local function anchor_position(relative_ui, anchor, point, relative_point)
        anchor.point = anchor.point or point
        anchor.relative_point = anchor.relative_point or relative_point
        anchor.relative_ui = anchor.relative_ui or relative_ui
        o.anchor.set(create_anchor(anchor))
    end

    local anchor_methods = {
        anchor_center = { point = "center", relative_point = "center", x = 1, y = 1 },
        anchor_left_outer = { point = "right_center", relative_point = "left_center", x = -1, y = 1 },
        anchor_right_outer = { point = "left_center", relative_point = "right_center", x = 1, y = 1 },
        anchor_top_outer = { point = "bottom_center", relative_point = "top_center", x = 1, y = -1 },
        anchor_bottom_outer = { point = "top_center", relative_point = "bottom_center", x = 1, y = 1 },
        anchor_right_top_outer = { point = "left_top", relative_point = "right_top", x = 1, y = -1 },
        anchor_top_right_outer = { point = "right_bottom", relative_point = "right_top", x = -1, y = 1 },
        anchor_right_bottom_outer = { point = "left_bottom", relative_point = "right_bottom", x = 1, y = 1 },
        anchor_left_top_outer = { point = "right_top", relative_point = "left_top", x = -1, y = -1 },
        anchor_top_left_outer = { point = "left_bottom", relative_point = "left_top", x = 1, y = 1 },
        anchor_left_bottom_outer = { point = "right_bottom", relative_point = "left_bottom", x = -1, y = 1 },
        anchor_left_inner = { point = "left_center", relative_point = "left_center", x = 1, y = 1 },
        anchor_right_inner = { point = "right_center", relative_point = "right_center", x = -1, y = 1 },
        anchor_top_inner = { point = "top_center", relative_point = "top_center", x = 1, y = -1 },
        anchor_bottom_inner = { point = "bottom_center", relative_point = "bottom_center", x = 1, y = 1 },
    }

    for name, spec in pairs(anchor_methods) do
        o[name] = function(target_ui, opts)
            local anchor = {}
            if opts then
                if opts.horizontal_space then
                    anchor.x = spec.x * opts.horizontal_space
                end
                if opts.vertical_space then
                    anchor.y = spec.y * opts.vertical_space
                end
            end
            anchor_position(target_ui, anchor, spec.point, spec.relative_point)
        end
    end

    ---@param position framework.ui.position
    ---@param x? number
    ---@param y? number
    ---@param width? number
    ---@param height? number
    ---@return number x
    ---@return number y
    local function compute_target_position(position, x, y, width, height)
        local window_size = o.window_size()
        local window_width, window_height = window_size.width, window_size.height
        x = x or window_width / 2
        y = y or window_height / 2
        width = width or window_width
        height = height or window_height

        if position == "center_top" or position == "top_center" or position == "center" or position == "center_bottom" or position == "bottom_center" then
            x = x + 0
        elseif position == "left_top" or position == "top_left" or position == "left_center" or position == "center_left" or position == "left_bottom" or position == "bottom_left" then
            x = x - width / 2
        elseif position == "right_top" or position == "top_right" or position == "right_center" or position == "center_right" or position == "right_bottom" or position == "bottom_right" then
            x = x + width / 2
        else
            error("not implemented")
        end

        if position == "center_left" or position == "left_center" or position == "center" or position == "center_right" or position == "right_center" then
            y = y + 0
        elseif position == "top_left" or position == "left_top" or position == "center_top" or position == "top_center" or position == "top_right" or position == "right_top" then
            y = y + height / 2
        elseif position == "bottom_left" or position == "left_bottom" or position == "bottom_center" or position == "center_bottom" or position == "bottom_right" or position == "right_bottom" then
            y = y - height / 2
        else
            error("not implemented")
        end

        return x, y
    end

    ---@param position framework.ui.position
    ---@param x number
    ---@param y number
    ---@return number x
    ---@return number y
    local function compute_self_position(position, x, y)
        local width, height = o.visual_size()

        if position == "center_top" or position == "top_center" or position == "center" or position == "center_bottom" or position == "bottom_center" then
            x = x + 0
        elseif position == "left_top" or position == "top_left" or position == "left_center" or position == "center_left" or position == "left_bottom" or position == "bottom_left" then
            x = x + width / 2
        elseif position == "right_top" or position == "top_right" or position == "right_center" or position == "center_right" or position == "right_bottom" or position == "bottom_right" then
            x = x - width / 2
        else
            error("not implemented")
        end

        if position == "center_left" or position == "left_center" or position == "center" or position == "center_right" or position == "right_center" then
            y = y + 0
        elseif position == "top_left" or position == "left_top" or position == "center_top" or position == "top_center" or position == "top_right" or position == "right_top" then
            y = y - height / 2
        elseif position == "bottom_left" or position == "left_bottom" or position == "bottom_center" or position == "center_bottom" or position == "bottom_right" or position == "right_bottom" then
            y = y + height / 2
        else
            error("not implemented")
        end

        return x, y
    end

    ---@param x number
    ---@param y number
    ---@param x_offset number
    ---@param y_offset number
    ---@param basis_width? number
    ---@param basis_height? number
    ---@return number x
    ---@return number y
    local function compute_offset(x, y, x_offset, y_offset, basis_width, basis_height)
        if basis_width == nil or basis_height == nil then
            local window_size = o.window_size()
            basis_width, basis_height = window_size.width, window_size.height
        end
        return x + x_offset * basis_width, y + y_offset * basis_height
    end

    ---@param anchor framework.ui.anchor
    ---@return point position
    local function render_target(anchor)
        ---@type framework.ui
        local target = anchor.relative_ui
        ---@type framework.ui.position
        local position = anchor.point
        ---@type framework.ui.position
        local target_position = anchor.relative_point

        local target_width, target_height = target.visual_size()
        local p = target.pixel_position()
        local x, y = p.x, p.y

        x, y = compute_target_position(target_position, x, y, target_width, target_height)
        x, y = compute_self_position(position, x, y)
        x, y = compute_offset(x, y, anchor.x, anchor.y, target_width, target_height)

        return { x = x, y = y }
    end

    ---@param anchor framework.ui.anchor
    ---@return point position
    local function render_window(anchor)
        local x, y = compute_target_position(anchor.relative_point)
        x, y = compute_self_position(anchor.point, x, y)

        local window_size = o.window_size()
        local window_width, window_height = window_size.width, window_size.height
        x, y = compute_offset(x, y, anchor.x, anchor.y, window_width, window_height)

        return { x = x, y = y }
    end

    ---@type reactive.computed<framework.ui.position>
    local render_position = o.factory.computed_field("render_position", function()
            ---@type framework.ui.anchor
            local anchor = o.anchor()

            if anchor.relative_ui == nil then
                return render_window(anchor)
            end
            return render_target(anchor)
    end)

    render_position.on_update.add(function(position)
        o.pixel_position.set(position)
    end)

    o.anchor.wrap_set(function(anchor)
        local old_anchor = o.anchor()
        local old_point = old_anchor and old_anchor.point
        local old_relative_point = old_anchor and old_anchor.relative_point
        local old_x = old_anchor and old_anchor.x
        local old_y = old_anchor and old_anchor.y
        local old_relative_ui = old_anchor and old_anchor.relative_ui

        anchor = create_anchor(anchor)
        anchor.point = anchor.point or old_point
        anchor.relative_point = anchor.relative_point or old_relative_point
        anchor.x = anchor.x or old_x
        anchor.y = anchor.y or old_y
        anchor.relative_ui = anchor.relative_ui or old_relative_ui

        anchor.x = anchor.x >= -1 and anchor.x <= 1 and anchor.x or 0
        anchor.y = anchor.y >= -1 and anchor.y <= 1 and anchor.y or 0
        anchor.x = math.floor(anchor.x * 1000000) / 1000000
        anchor.y = math.floor(anchor.y * 1000000) / 1000000

        return anchor
    end)

    o.anchor.wrap_equal(function(anchor, old_anchor)
        return old_anchor
            and old_anchor.point == anchor.point
            and old_anchor.relative_point == anchor.relative_point
            and old_anchor.x == anchor.x
            and old_anchor.y == anchor.y
            and old_anchor.relative_ui == anchor.relative_ui
    end)

    render_position.auto_update()
end
