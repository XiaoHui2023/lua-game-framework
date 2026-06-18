---@type framework.ui
local M = require "framework.ui.base"
---@type framework.event
local event = require "framework.event"

---@class ui.anchor_position.options : ui.anchor
---@field vertical_space? number 纵向间距偏移
---@field horizontal_space? number 横向间距偏移

---@param o ui
---@param args ui.options
return function (o,args)
    args.anchor = args.anchor or M.anchor()
    
    ---@class ui
    o = o

    ---@type lib.reactive.ref
    o.anchor = o.factory.set(args.anchor)

    ---@param relative_ui ui 目标UI
    ---@param anchor ui.anchor 锚点配置
    ---@param point ui.position 当前 UI 锚点方位
    ---@param relative_point ui.position 目标 UI 锚点方位
    local function anchor_position(relative_ui,anchor,point,relative_point)
        anchor.point = anchor.point or point
        anchor.relative_point = anchor.relative_point or relative_point
        anchor.relative_ui = anchor.relative_ui or relative_ui
        anchor = M.anchor(anchor)
        -- 应用
        o.anchor.set(anchor)
    end

    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_center = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"center","center")
    end

    -- 外侧贴合左边
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_left_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = -opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"right_center","left_center")
    end

    -- 外侧贴合右边
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_right_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"left_center","right_center")
    end

    -- 外侧贴合顶部
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_top_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = -opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"bottom_center","top_center")
    end

    -- 外侧贴合底部
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_bottom_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"top_center","bottom_center")
    end

    -- 外侧贴合右上
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_right_top_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = -opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"left_top","right_top")
    end

    -- 外侧贴合上右
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_top_right_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = -opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"right_bottom","right_top")
    end

    -- 外侧贴合右下
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_right_bottom_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"left_bottom","right_bottom")
    end

    -- 外侧贴合左上
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_left_top_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = -opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = -opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"right_top","left_top")
    end

    -- 外侧贴合上左
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_top_left_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"left_bottom","left_top")
    end

    -- 外侧贴合左下
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_left_bottom_outer = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = -opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"right_bottom","left_bottom")
    end

    -- 内侧贴合左边
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_left_inner = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"left_center","left_center")
    end

    -- 内侧贴合右边
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_right_inner = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = -opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"right_center","right_center")
    end

    -- 内侧贴合顶部
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_top_inner = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = -opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"top_center","top_center")
    end

    -- 内侧贴合底部
    ---@param target_ui ui 目标UI
    ---@param opts ui.anchor_position.options? 间距偏移配置
    o.anchor_bottom_inner = function (target_ui,opts)
        local anchor = {}
        if opts then
            if opts.horizontal_space then
                anchor.x = opts.horizontal_space
            end
            if opts.vertical_space then
                anchor.y = opts.vertical_space
            end
        end
        anchor_position(target_ui,anchor,"bottom_center","bottom_center")
    end

    -- 计算目标的方位
    ---@param position ui.position 方位
    ---@param x? number 目标中心横坐标
    ---@param y? number 目标中心纵坐标
    ---@param width? number 目标宽度
    ---@param height? number 目标高度
    ---@return number x 横坐标
    ---@return number y 纵坐标
    local function compute_target_position(position,x,y,width,height)
        local window_width,window_height = o.window_size()
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

        return x,y
    end

    -- 计算自身的方位
    ---@param position ui.position 方位
    ---@param x number 横坐标
    ---@param y number 纵坐标
    ---@return number x 横坐标
    ---@return number y 纵坐标
    local function compute_self_position(position,x,y)
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

        return x,y
    end

    -- 计算偏移
    ---@param x number 横坐标
    ---@param y number 纵坐标
    ---@param x_offset number 横偏移（百分比）
    ---@param y_offset number 纵偏移（百分比）
    ---@return number x 横坐标
    ---@return number y 纵坐标
    local function compute_offset(x,y,x_offset,y_offset)
        local window_width, window_height = o.window_size()
        x = x + x_offset*window_width
        y = y + y_offset*window_height
        return x,y
    end

    -- 渲染目标
    ---@param anchor ui.anchor
    ---@return point
    local function render_target(anchor)
        ---@type ui
        local target = anchor.relative_ui
        ---@type ui.position
        local position = anchor.point
        ---@type ui.position
        local target_position = anchor.relative_point
        
        local target_width, target_height = target.visual_size()

        -- 起点
        local p = target.pixel_position()
        local x,y = p.x,p.y

        -- 计算目标的方位
        x,y = compute_target_position(target_position,x,y,target_width,target_height)
        -- 计算自身的方位
        x,y = compute_self_position(position,x,y)
        -- 计算偏移（百分比）
        x,y = compute_offset(x,y,anchor.x,anchor.y)
        
        return {x=x, y=y}
    end

    -- 渲染窗口
    ---@param anchor ui.anchor
    ---@return point
    local function render_window(anchor)
        -- 计算世界方位
        local x,y = compute_target_position(anchor.relative_point)
    
        -- 计算自身方位
        x,y = compute_self_position(anchor.point,x,y)

        -- 计算偏移（百分比）
        x,y = compute_offset(x,y,anchor.x,anchor.y)

        return {x=x, y=y}
    end

    ---@type reactive.computed 渲染位置<ui.position>
    local render_position = o.factory.computed(function()
        ---@type ui.anchor
        local anchor = o.anchor()
        
        if anchor.relative_ui == nil then
            return render_window(anchor)
        else
            return render_target(anchor)
        end
    end)

    -- 应用
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

        -- 默认值
        anchor = M.anchor(anchor)
        anchor.point = anchor.point or old_point
        anchor.relative_point = anchor.relative_point or old_relative_point
        anchor.x = anchor.x or old_x
        anchor.y = anchor.y or old_y
        anchor.relative_ui = anchor.relative_ui or old_relative_ui

        anchor.x = anchor.x >= -1 and anchor.x <= 1 and anchor.x or 0
        anchor.y = anchor.y >= -1 and anchor.y <= 1 and anchor.y or 0
        anchor.x = math.floor(anchor.x * 1000) / 1000
        anchor.y = math.floor(anchor.y * 1000) / 1000

        return anchor
    end)
    o.anchor.wrap_equal(function(anchor, old_anchor)
        return old_anchor and old_anchor.point == anchor.point and old_anchor.relative_point == anchor.relative_point and old_anchor.x == anchor.x and old_anchor.y == anchor.y and old_anchor.relative_ui == anchor.relative_ui
    end)

    -- 绑定到帧更新
    render_position.auto_update()
end
