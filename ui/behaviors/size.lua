---@type framework.ui
local g = require "..base"
---@type framework.event
local event = require "framework.event"

---@alias ui.size_mode
---| "fill" 拉伸
---| "contain" 保持

---@class ui.options
---@field scale_factor? number 缩放因子
---@field width_scale_factor? number 宽度缩放因子
---@field height_scale_factor? number 高度缩放因子
---@field size_mode? ui.size_mode 尺寸模式
---@field width? number 宽度
---@field height? number 高度
---@field size? number 宽度和高度（百分比）

---@param o ui
---@param args ui.options
return function (o,args)
    args.scale_factor = args.scale_factor or 1
    args.width_scale_factor = args.width_scale_factor or 1
    args.height_scale_factor = args.height_scale_factor or 1
    args.size_mode = args.size_mode or "fill"
    args.size = args.size or 0.04
    args.width = args.width or args.size or args.height
    args.height = args.height or args.size or args.width

    ---@class ui
    o = o

    ---@type hook.computed 百分比大小<number,number>（直接设置的参数）
    o.relative_size = o.factory.computed(function()
        return args.width, args.height
    end)

    ---@type hook.computed 像素大小<number,number>（衍生出的值）
    o.pixel_size = o.factory.computed(function()
        local width_percent, height_percent = o.relative_size()
        local window_width, window_height = o.window_size()
        local pixel_width = window_width * width_percent
        local pixel_height = window_height * height_percent
        -- 尺寸模式
        local size_ratio = o.size_ratio()
        if size_ratio > 1 then
            pixel_width = pixel_width / size_ratio
        elseif size_ratio < 1 then
            pixel_height = pixel_height * size_ratio
        end
        pixel_width = math.floor(pixel_width)
        pixel_height = math.floor(pixel_height)
        return pixel_width, pixel_height
    end)

    ---@type hook.set 整体缩放因子<number>
    o.scale_factor = o.factory.set(args.scale_factor)

    ---@type hook.set 宽度缩放因子<number>
    o.width_scale_factor = o.factory.set(args.width_scale_factor)

    ---@type hook.set 高度缩放因子<number>
    o.height_scale_factor = o.factory.set(args.height_scale_factor)

    ---@type hook.set 窗口大小<number,number>
    o.window_size = o.factory.set(g.get_window_width(), g.get_window_height())

    ---@type hook.set 尺寸模式<ui.size_mode>
    o.size_mode = o.factory.set(args.size_mode)
    
    ---@type hook.computed 宽高比（宽 ÷ 高），用于保持对象缩放时为正方形或固定比例
    o.size_ratio = o.factory.computed(function()
        ---@type ui.size_mode
        local size_mode = o.size_mode()
        if size_mode == "fill" then
            local width,height = o.window_size()
            return width / height
        elseif size_mode == "contain" then
            return 1
        end
    end)

    ---@type hook.computed 得到大小总缩放（从最父级开始计算）<width:number,height:number>
    o.total_size_scale_factor = o.factory.computed(function()
        local scale_factor = o.scale_factor()
        local width_scale_factor = o.width_scale_factor()
        local height_scale_factor = o.height_scale_factor()
        width_scale_factor = width_scale_factor * scale_factor
        height_scale_factor = height_scale_factor * scale_factor
        ---@type ui
        local parent = o.parent()
        if parent then
            local parent_width_scale_factor,parent_height_scale_factor = parent.total_size_scale_factor()
            width_scale_factor = width_scale_factor * parent_width_scale_factor
            height_scale_factor = height_scale_factor * parent_height_scale_factor
        end
        return width_scale_factor, height_scale_factor
    end)
    
    -- 按缩放因子缩放尺寸
    ---@param width number? 宽度
    ---@param height number? 高度
    ---@return number? width 宽度
    ---@return number? height 高度
    local function scale_size(width, height)
        local scale_factor = o.scale_factor()
        local width_scale_factor = o.width_scale_factor()
        local height_scale_factor = o.height_scale_factor()
        local width_scale_factor, height_scale_factor = scale_factor * width_scale_factor, scale_factor * height_scale_factor
        width = width * width_scale_factor
        height = height * height_scale_factor
        return width, height
    end
    
    -- 按总计缩放因子缩放尺寸
    ---@param width number? 宽度
    ---@param height number? 高度
    ---@return number? width 宽度
    ---@return number? height 高度
    local function total_scale_size(width, height)
        local width_scale_factor, height_scale_factor = o.total_size_scale_factor()
        width = width * width_scale_factor
        height = height * height_scale_factor
        return width, height
    end

    ---@type hook.computed 缩放过的相对尺寸
    o.scaled_relative_size = o.factory.computed(function ()
        return scale_size(o.relative_size())
    end)

    ---@type hook.computed 缩放过的像素尺寸
    o.scaled_pixel_size = o.factory.computed(function ()
        return scale_size(o.pixel_size())
    end)

    ---@type hook.computed 总计缩放过的相对尺寸
    o.total_scaled_relative_size = o.factory.computed(function ()
        return total_scale_size(o.relative_size())
    end)

    ---@type hook.computed 总计缩放过的像素尺寸
    o.total_scaled_pixel_size = o.factory.computed(function ()
        return total_scale_size(o.pixel_size())
    end)

    ---@type hook.computed 实际尺寸（决定应用）
    o.actual_size = o.factory.computed(function ()
        return o.total_scaled_pixel_size()
    end)

    ---@type hook.computed 视觉尺寸（像素）
    o.visual_size = o.factory.computed(function()
        return o.actual_size()
    end)

    -- 应用大小
    o.actual_size.on_change.add(function(width,height,...)
        g.set_size(o, width, height)
    end)

    -- 绑定窗口大小改变事件
    o.delete.add(g.ON_WINDOW_SIZE_CHANGE(function(api)
        o.window_size.set(api.width, api.height)
    end))

    -- 包装相对尺寸获取
    o.relative_size.wrap_compute(function(width, height)
        width = (width > 1 and 1) or (width < 0 and 0) or width
        height = (height > 1 and 1) or (height < 0 and 0) or height
        width = math.floor(width * 1000) / 1000
        height = math.floor(height * 1000) / 1000
        return width, height
    end)

    -- 绑定到帧更新
    o.actual_size.auto_update()
end
