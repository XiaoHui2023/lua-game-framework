---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"
---@type framework.event
local event = require "framework.event"

---@alias framework.ui.size_mode
---| "fill" 拉伸
---| "contain" 保持

---@param o framework.ui 要装配尺寸能力的 UI 对象
---@param args framework.ui.options UI 创建参数
return function (o,args)
    args.scale_factor = args.scale_factor or 1
    args.width_scale_factor = args.width_scale_factor or 1
    args.height_scale_factor = args.height_scale_factor or 1
    args.size_mode = args.size_mode or "fill"
    args.size = args.size or 0.04
    args.width = args.width or args.size or args.height
    args.height = args.height or args.size or args.width

    ---@class framework.ui
    o = o

    o.is_content_sized = false

    local function get_size_basis()
        ---@type framework.ui
        local parent = o.parent()
        if parent and not parent.is_content_sized and parent.pixel_size then
            return parent.pixel_size()
        end
        return o.window_size()
    end

    ---@type reactive.computed 百分比大小<number,number>，来自创建参数
    o.factory.relative_size.computed(function()
        return args.width, args.height
    end)

    ---@type reactive.computed 像素大小<number,number>（衍生出的值）
    o.factory.pixel_size.computed(function()
        local width_percent, height_percent = o.relative_size()
        local basis_width, basis_height = get_size_basis()
        local pixel_width = basis_width * width_percent
        local pixel_height = basis_height * height_percent
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

    ---@type lib.reactive.ref 整体缩放因子<number>
    o.factory.scale_factor.set(args.scale_factor)

    ---@type lib.reactive.ref 宽度缩放因子<number>
    o.factory.width_scale_factor.set(args.width_scale_factor)

    ---@type lib.reactive.ref 高度缩放因子<number>
    o.factory.height_scale_factor.set(args.height_scale_factor)

    ---@type lib.reactive.ref 窗口大小<number,number>
    local window_size_api = apis.GET_WINDOW_SIZE({})
    assert(window_size_api.width ~= nil, "framework.ui.size requires runtime backend width")
    assert(window_size_api.height ~= nil, "framework.ui.size requires runtime backend height")
    o.factory.window_size.set(window_size_api.width, window_size_api.height)

    ---@type lib.reactive.ref 尺寸模式<framework.ui.size_mode>
    o.factory.size_mode.set(args.size_mode)
    
    ---@type reactive.computed 宽高比，宽度除以高度，用于保持正方形或固定比例
    o.factory.size_ratio.computed(function()
        ---@type framework.ui.size_mode
        local size_mode = o.size_mode()
        if size_mode == "fill" then
            local width,height = get_size_basis()
            return width / height
        elseif size_mode == "contain" then
            return 1
        end
    end)

    ---@type reactive.computed 得到大小总缩放（从最父级开始计算）<width:number,height:number>
    o.factory.total_size_scale_factor.computed(function()
        local scale_factor = o.scale_factor()
        local width_scale_factor = o.width_scale_factor()
        local height_scale_factor = o.height_scale_factor()
        width_scale_factor = width_scale_factor * scale_factor
        height_scale_factor = height_scale_factor * scale_factor
        ---@type framework.ui
        local parent = o.parent()
        if parent then
            local parent_width_scale_factor,parent_height_scale_factor = parent.total_size_scale_factor()
            width_scale_factor = width_scale_factor * parent_width_scale_factor
            height_scale_factor = height_scale_factor * parent_height_scale_factor
        end
        return width_scale_factor, height_scale_factor
    end)
    
    -- 按缩放因子缩放尺寸。
    ---@param width number? 原始宽度
    ---@param height number? 原始高度
    ---@return number? width 缩放后宽度
    ---@return number? height 缩放后高度
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
    ---@param width number? 原始宽度
    ---@param height number? 原始高度
    ---@return number? width 总计缩放后宽度
    ---@return number? height 总计缩放后高度
    local function total_scale_size(width, height)
        local width_scale_factor, height_scale_factor = o.total_size_scale_factor()
        width = width * width_scale_factor
        height = height * height_scale_factor
        return width, height
    end

    ---@type reactive.computed 缩放过的相对尺寸
    o.factory.scaled_relative_size.computed(function ()
        return scale_size(o.relative_size())
    end)

    ---@type reactive.computed 缩放过的像素尺寸
    o.factory.scaled_pixel_size.computed(function ()
        return scale_size(o.pixel_size())
    end)

    ---@type reactive.computed 总计缩放过的相对尺寸
    o.factory.total_scaled_relative_size.computed(function ()
        return total_scale_size(o.relative_size())
    end)

    ---@type reactive.computed 总计缩放过的像素尺寸
    o.factory.total_scaled_pixel_size.computed(function ()
        return total_scale_size(o.pixel_size())
    end)

    ---@type reactive.computed 实际尺寸（决定应用）
    o.factory.actual_size.computed(function ()
        local width, height = o.total_scaled_pixel_size()
        local scale = M.settings.UI_APPLICATION_SIZE_SCALE
        return width * scale, height * scale
    end)

    ---@type reactive.computed 视觉尺寸（像素）
    o.factory.visual_size.computed(function()
        return o.actual_size()
    end)

    -- 应用大小
    o.actual_size.on_change.add(function(width,height,...)
        apis.SET_SIZE({ ui = o, width = width, height = height })
    end)

    -- 绑定窗口大小改变事件
    o.delete.add(apis.ON_WINDOW_SIZE_CHANGE(function(api)
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
