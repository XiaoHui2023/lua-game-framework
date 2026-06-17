---@type lib.tablex
local table = require "lib.tablex"
---@class framework.ui
local g = require "..base"

---@alias ui.container.mode
---| 'single' 鍙樉绀轰紭鍏堢骇鏈€楂樼殑涓€涓帶浠?---| 'stack' 鍏ㄩ儴鎺т欢閮藉彲瑙侊紝鎸夌収椤哄簭/甯冨眬鎺掑紑
---| 'toggle' 妲戒綅鍐呭彲浠ュ垏鎹㈠綋鍓嶆縺娲荤殑鎺т欢
---| 'overlay' 鎵€鏈夋帶浠堕兘鏄剧ず锛屼絾鎸夊眰绾у彔鏀?
---@alias ui.container.layout.type
---| "horizontal"  -- 姘村钩鎺掑垪
---| "vertical"    -- 鍨傜洿鎺掑垪
---| "grid"        -- 缃戞牸鎺掑垪

---@alias ui.container.layout.flow
---| "top_to_bottom"  -- 浠庝笂鍒颁笅
---| "bottom_to_top"  -- 浠庝笅鍒颁笂
---| "left_to_right"  -- 浠庡乏鍒板彸
---| "right_to_left"  -- 浠庡彸鍒板乏

---@alias ui.container.layout.grid_wrap
---| "row"  -- 琛屼紭鍏?---| "column"  -- 鍒椾紭鍏?
---@class ui.container.layout.options
---@field type? ui.container.layout.type 褰撳墠浣跨敤鐨勫竷灞€绫诲瀷锛坔orizontal / vertical / grid锛?---@field flow? ui.container.layout.flow 鎺掑垪鏂瑰悜锛坔orizontal/vertical 鏃剁敓鏁堬級
---@field reverse? boolean 鏄惁鍙嶅悜鎺掑垪锛堢瓑浠蜂簬 flow 鐨勫揩鎹风敤娉曪級
---@field spacing? number 鎺т欢涔嬮棿鐨勯棿璺?---@field padding? number 澶栬竟璺?---@field grid_columns? integer 缃戞牸鍒楁暟
---@field grid_rows? integer 缃戞牸琛屾暟
---@field grid_wrap? ui.container.layout.grid_wrap 缃戞牸鎹㈣鏂瑰紡锛堣浼樺厛 / 鍒椾紭鍏堬級
---@field grid_spacing? {x:number, y:number} 缃戞牸妯旱闂磋窛

---@class ui.container.options: ui.options
---@field mode? ui.container.mode 妯″紡
---@field layout? ui.container.layout.options 甯冨眬

-- 瀹瑰櫒
---@param args? ui.container.options
---@param ... ui.container.options
---@return ui.container
g.container = function(args,...)
    args = args or {}
    args = table.merge(args, ...)
    args.mode = args.mode or "single"
    args.layout = args.layout or {}
    args.layout.type = args.layout.type or "horizontal"
    args.layout.flow = args.layout.flow or (args.layout.type == "vertical" and "top_to_bottom" or "left_to_right")
    args.layout.reverse = args.layout.reverse or false
    args.layout.spacing = args.layout.spacing or 0
    args.layout.padding = args.layout.padding or 0
    args.layout.grid_columns = args.layout.grid_columns or 1
    args.layout.grid_rows = args.layout.grid_rows or 1
    args.layout.grid_wrap = args.layout.grid_wrap or "row"
    args.layout.grid_spacing = args.layout.grid_spacing or {x = 0, y = 0}

    ---@class ui.container: ui.void
    ---@field layout ui.container.layout 甯冨眬
    local o = g.void(args)

    ---@type hook.add<ui> 鎺т欢
    o.widgets = o.factory.add({
        ---@param a ui
        ---@param b ui
        ---@return boolean
        compare = function(a, b)
            return a.priority() < b.priority()
        end,
    })

    ---@type hook.set<ui.container.mode> 妯″紡
    o.mode = o.factory.set(args.mode)

    ---@class ui.container.layout 甯冨眬
    o.layout = {}

    ---@type hook.set<ui.container.layout.type> 甯冨眬绫诲瀷
    o.layout.type = o.factory.set(args.layout.type)

    ---@type hook.set<ui.container.layout.flow> 鎺掑垪鏂瑰悜
    o.layout.flow = o.factory.set(args.layout.flow)

    ---@type hook.set<boolean> 鏄惁鍙嶅悜鎺掑垪
    o.layout.reverse = o.factory.set(args.layout.reverse)

    ---@type hook.set<number> 鎺т欢涔嬮棿鐨勯棿璺?
    o.layout.spacing = o.factory.set(args.layout.spacing)

    ---@type hook.set<number> 澶栬竟璺?
    o.layout.padding = o.factory.set(args.layout.padding)

    ---@type hook.set<integer> 缃戞牸鍒楁暟
    o.layout.grid_columns = o.factory.set(args.layout.grid_columns)
    
    ---@type hook.set<integer> 缃戞牸琛屾暟
    o.layout.grid_rows = o.factory.set(args.layout.grid_rows)

    ---@type hook.set<ui.container.layout.grid_wrap> 缃戞牸鎹㈣鏂瑰紡
    o.layout.grid_wrap = o.factory.set(args.layout.grid_wrap)

    ---@type hook.set<{x:number, y:number}> 缃戞牸妯旱闂磋窛
    o.layout.grid_spacing = o.factory.set(args.layout.grid_spacing)

    -- 娣诲姞涓嬬骇
    ---@param ui ui
    o.add_child = function (ui)
        o.widgets.add(ui)
    end

    -- 鎸夊垪琛ㄩ『搴忔坊鍔犱笅绾?    ---@param uis ui[]
    o.add_children = function (uis)
        for _, ui in ipairs(uis) do
           o.add_child(ui) 
        end
    end

    ---@type hook.computed<ui?> 浼樺厛绾ф渶楂樼殑鎺т欢
    local primary_widget = o.factory.computed(function()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return nil
        end
        return widgets.first()
    end)

    ---@type hook.once_event 娓呴櫎鍒锋柊浜嬩欢 
    local once_clear_refresh = o.factory.once_event()

    -- 寰楀埌single瑙嗚澶у皬
    local function get_single_visual_size()
        ---@type ui
        local ui = primary_widget()
        return ui.visual_size()
    end

    -- 寰楀埌stack瑙嗚澶у皬
    local function get_stack_visual_size()
        ---@type list<ui>
        local widgets = o.widgets()
        ---@type ui.container.layout.type
        local type = o.layout.type()
        
        if type == "horizontal" then
            ---@type number 鏈€澶ч珮搴?
            local max_height = 0
            ---@type number 瀹藉害鎬诲拰
            local width_sum = 0
            widgets.for_each(
                ---@param widget ui
                function(widget)
                    local width,height = widget.visual_size()
                    if height > max_height then
                        max_height = height
                    end
                    width_sum = width_sum + width
                end
            )
            return width_sum, max_height
        elseif type == "vertical" then
            ---@type number 鏈€澶у搴?
            local max_width = 0
            ---@type number 楂樺害鎬诲拰
            local height_sum = 0
            widgets.for_each(
                ---@param widget ui
                function(widget)
                    local width,height = widget.visual_size()
                    if width > max_width then
                        max_width = width
                    end
                    height_sum = height_sum + height
                end
            )
            return max_width, height_sum
        else
            error("not implemented")
        end
    end

    -- 璁剧疆鍍忕礌澶у皬
    o.pixel_size.compute(function()
        ---@type ui.container.mode
        local mode = o.mode()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return 0,0
        end
        if mode == "single" then
            return get_single_visual_size()
        elseif mode == "stack" then
            return get_stack_visual_size()
        else
            error("not implemented")
        end
    end)
    
    --- single甯冨眬
    local function layout_single()
        ---@type ui
        local ui = primary_widget()
        ---@type list<ui>
        local widgets = o.widgets()
        if ui == nil then
            return
        end
        -- 鍙樉绀轰竴涓?
        widgets.for_each(
            ---@param widget ui
            function(widget)
                if widget == ui then
                    return
                end
                once_clear_refresh(widget.hide_lock.acquire()) -- 鑾峰彇闅愯棌閿?
            end
        )

        ui.anchor_center(o)
    end

    --- stack甯冨眬
    local function layout_stack()
        ---@type list<ui>
        local widgets = o.widgets()
        if widgets.count == 0 then
            return
        end
        ---@type ui.container.layout.type
        local type = o.layout.type()
        ---@type ui.container.layout.flow
        local flow = o.layout.flow()
        ---@type boolean
        local reverse = o.layout.reverse()

        ---@type ui
        local last

        widgets.for_each(
            ---@param widget ui
            function(widget)
                ---@type ui.position
                local point
                ---@type ui.position
                local relative_point
                ---@type ui
                local relative_ui

                if last then
                    if type == "horizontal" then
                        if (flow == "left_to_right" and not reverse) or (flow == "right_to_left" and reverse) then
                            point = "left_center"
                            relative_point = "right_center"
                        elseif (flow == "left_to_right" and reverse) or (flow == "right_to_left" and not reverse) then
                            point = "right_center"
                            relative_point = "left_center"
                        end
                    elseif type == "vertical" then
                        if (flow == "top_to_bottom" and not reverse) or (flow == "bottom_to_top" and reverse) then
                            point = "top_center"
                            relative_point = "bottom_center"
                        elseif (flow == "top_to_bottom" and reverse) or (flow == "bottom_to_top" and not reverse) then
                            point = "bottom_center"
                            relative_point = "top_center"
                        end
                    end
                    relative_ui = last
                else
                    if type == "horizontal" then
                        if (flow == "left_to_right" and not reverse) or (flow == "right_to_left" and reverse) then
                            point = "left_center"
                            relative_point = "left_center"
                        elseif (flow == "left_to_right" and reverse) or (flow == "right_to_left" and not reverse) then
                            point = "right_center"
                            relative_point = "right_center"
                        end
                    elseif type == "vertical" then
                        if (flow == "top_to_bottom" and not reverse) or (flow == "bottom_to_top" and reverse) then
                            point = "top_center"
                            relative_point = "top_center"
                        elseif (flow == "top_to_bottom" and reverse) or (flow == "bottom_to_top" and not reverse) then
                            point = "bottom_center"
                            relative_point = "bottom_center"
                        end
                    end
                    relative_ui = o
                end
                widget.anchor.set({
                    point = point,
                    relative_point = relative_point,
                    x = 0,
                    y = 0,
                    relative_ui = relative_ui,
                })
                last = widget
            end
        )
    end

    --- 鍒锋柊甯冨眬
    local function refresh_layout()
        ---@type ui.container.mode
        local mode = o.mode()
        if mode == "single" then
            layout_single()
        elseif mode == "stack" then
            layout_stack()
        else
            error("not implemented")
        end
    end

    -- 閲嶈浇娣诲姞鎺т欢
    o.widgets.on_add.add(
        ---@param widget ui
        function(widget)
            -- 娣诲姞涓嬬骇
            o.children.add(widget)
            o.factory.capture("", widget)

            -- 瑙﹀彂娓呴櫎鍒锋柊浜嬩欢
            once_clear_refresh()

            -- 鍒锋柊甯冨眬
            refresh_layout()
        end
    )

    return o
end

return g
