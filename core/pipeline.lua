---@type utils.hook
local hook = require "utils.hook"

---@alias core.pipeline.options
---| "chain" 链式（累积值）。默认返回初始值
---| "first" 取第一个有效值。返回空表示无效
---| "min" 取最小值（初始值）。默认返回初始值
---| "max" 取最大值（初始值）。默认返回初始值
---| "and" 与。任何一个修改器返回False则返回False，否则返回True。默认返回True
---| "or" 或。任何一个修改器返回True则返回True，否则返回False。默认返回False

---@class core.pipeline.modifier 修改器
---@field callback fun(context:any,data?:any):any? 修改函数（返回空表示无效）
---@field priority? number 优先级（越小越优先）
---@field enabled? boolean 是否启用
---@field source? any 来源
---@field name? string 名称
---@field delete? fun() 删除函数

---@class system.modify_context
---@field modifier core.pipeline.modifier 当前修改器
---@field before any 修改前的值
---@field after any 修改后的值
---@field index number 当前修改器索引（从1开始）
---@field context any 上下文数据

-- 流水线
---@param option core.pipeline.options 选项
---@return core.pipeline
return function (option)
    ---@class core.pipeline: hook.factory
    local o = hook.factory()
    o.set_class("core.pipeline")

    ---@type hook.add 修改器<core.pipeline.modifier>
    o.modifiers = hook.add({
        compare = function(a, b)
            return a.priority < b.priority
        end,
    })
    o.modifiers.wrap_add(
        ---@param args core.pipeline.modifier 修改器参数
        ---@return core.pipeline.modifier 新的修改器对象
        function(args)
            local modifier = table.clone(args)
            modifier.priority = modifier.priority or 0
            modifier.enabled = modifier.enabled or true
            modifier.source = modifier.source or nil
            modifier.name = modifier.name or ""
            return modifier
        end
    )

    ---@type hook.event<system.modify_context> 修改一次事件
    o.on_modify = o.factory.event()

    ---@type hook.event<any> 运算事件
    o.on_run = o.factory.event()

    ---@type any 最近一次运算的输出值
    o.last_value = nil

    -- 运算一次
    ---@param context any 上下文数据
    ---@param first_data? any 初始值/累计值
    ---@return any 输出数据
    o.run = function(context,first_data)
        --- 数据
        local data
        ---@type core.pipeline.modifier? 最佳修改器
        local best_modifier

            -- 默认值
        if option == "chain" or option == "min" or option == "max" then
            data = first_data
        end

        if o.modifiers.any() then
            -- 默认值
            if option == "and" then
                data = true
            elseif option == "or" then
                data = false
            end

            -- 遍历修改器
            o.modifiers.get().for_each(
                ---@param modifier core.pipeline.modifier 修改器
                ---@param ctx list.for_each.context 上下文
                ---@return nil
                function(modifier,ctx)
                    if modifier.enabled then
                        local rt = modifier.callback(context,data)

                        ---@type boolean 修改器计算是否有效
                        local has_value = rt ~= nil
                        ---@type boolean 管道方法计算是否有效
                        local has_result = true
                        ---@type boolean 是否应该退出
                        local should_break = false

                        if has_value then
                            -- 记录最佳修改器
                            best_modifier = modifier

                            -- 返回值检查
                            if option == "min" or option == "max" then
                                ---@cast rt number
                                assert(type(rt) == "number", "return value must be a number")
                            elseif option == "and" or option == "or" then
                                ---@cast rt boolean
                                assert(type(rt) == "boolean", "return value must be a boolean")
                            end

                            -- 旧值
                            local old_value = data
                            -- 新值
                            local new_value = rt

                            -- 根据选项计算
                            if old_value ~= nil then
                                if option == "min" then
                                    has_result = old_value < new_value
                                elseif option == "max" then
                                    has_result = old_value > new_value
                                end
                            end
                            if option == "and" then
                                ---@cast new_value boolean
                                should_break = not new_value
                            elseif option == "or" then
                                ---@cast new_value boolean
                                should_break = new_value
                            elseif option == "first" then
                                should_break = true
                            end

                            -- 每次都触发
                            if option == "chain" or option == "and" or option == "or" then
                                -- 触发修改事件
                                o.on_modify.run({
                                    modifier = modifier,
                                    before = old_value,
                                    after = new_value,
                                    index = ctx.index,
                                    context = context,
                                })
                            end

                            -- 应用返回值
                            if has_result then
                                data = rt
                            end
                            
                            -- 是否应该退出
                            if should_break then
                                return ctx.stop()
                            end
                        end
                    end
                end
            )

            -- 只在整体结束后触发一次
            if best_modifier ~= nil then
                if option == "first" or option == "min" or option == "max" then
                    -- 触发修改事件
                    o.on_modify.run({
                        modifier = best_modifier,
                        before = data,
                        after = data,
                        index = 0,
                        context = context,
                    })
                end
            end
        end

        -- 记录输出值
        o.last_value = data

        -- 触发运算事件
        o.on_run.run(data)

        return data
    end

    -- ()
    metatable.callable(o, o.run)
    
    return o
end