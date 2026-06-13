---@class core.movement
local g = require ".base"
---@type utils.hook
local hook = require "utils.hook"

---@alias core.movement.handler.phase
---| "normal" 常规阶段
---| "post" 后处理

---@type table<core.movement.handler.phase, integer>
local TO_PHASE_ORDER = {
    ["normal"] = 1,
    ["post"] = 2,
}

-- 计算结果
---@param data core.movement.data 数据
---@return core.movement.result
local function compute(data)
    ---@type core.movement.result
    return {
        data = data,
        final_pos = {
            x = data.origin_pos.x + data.delta_pos.x,
            y = data.origin_pos.y + data.delta_pos.y,
        },
        final_z = data.origin_z + data.delta_z
    }
end

-- 比较函数
-- 按顺序比较：phase->exclusive->priority
---@param a core.movement.handler
---@param b core.movement.handler
---@return boolean
local function compare(a, b)
    if a.phase ~= b.phase then
        return TO_PHASE_ORDER[a.phase] < TO_PHASE_ORDER[b.phase]
    end

    if a.exclusive then
        return true
    elseif b.exclusive then
        return false
    end

    if a.priority ~= b.priority then
        return a.priority < b.priority
    end

    return false
end

---@class core.movement.handler.options
---@field name? string 节点名称
---@field enabled? boolean 是否启用
---@field tick? fun(data:core.movement.data) 帧回调
---@field should_run? fun(data:core.movement.data):boolean 回调函数。是否应该运行
---@field should_finish? fun():boolean 回调函数。是否应该结束
---@field priority? integer 优先级(越小越优先)
---@field phase? core.movement.handler.phase 阶段
---@field exclusive? boolean  是否独占（执行期间直接清空/暂停其他 handler）

-- 创建移动处理器
---@param args? core.movement.handler.options
---@return core.movement.handler
g.handler = function (args)
    args = args or {}
    args.enabled = args.enabled or true
    args.name = args.name or ""
    args.tick = args.tick or function (data)
    end
    args.should_run = args.should_run or function (data)
        return true
    end
    args.should_finish = args.should_finish or function ()
        return false
    end
    args.priority = args.priority or 0

    ---@class core.movement.handler : core.movement.handler.options
    ---@operator call(core.movement.data):nil
    local o = args
    
    ---@type hook.add<core.movement.handler> 下级处理器
    o.children = hook.add({
        compare = compare
    })

    ---@type hook.once_event 删除
    o.delete = hook.once_event()

    ---@type hook.event 帧前事件（system.movement.data）
    o.pre_tick = hook.event()

    ---@type hook.event 帧后（全部计算完）事件（system.movement.result）
    o.post_tick = hook.event()

    ---@type hook.event 结束事件
    o.on_finish = hook.event()

    -- 添加下级
    ---@param child core.movement.handler 下级处理器
    o.add = function(child)
       o.delete.mount(o.children.add(child))
    end

    -- 绑定上级
    ---@param parent core.movement.handler 上级处理器
    o.attach = function(parent)
        parent.add(o)
    end

    -- 执行
    ---@param data core.movement.data 数据
    ---@return boolean 是否正常运行
    o.execute = function(data)
        if not o.should_run(data) then
            return false
        end

        ---@type table
        local children = o.children()

        -- 帧前
        o.pre_tick(data)

        -- 帧
        o.tick(data)

        -- 下级帧
        children.map(
            ---@param child core.movement.handler
            ---@param context list.for_each.context
            ---@return any
            function(child,context)
                -- 执行失败则跳过
                if not child.execute(data) then
                    return
                end

                -- 独占则停止
                if child.exclusive then
                    return context.stop()
                end
            end
        )

        return true
    end

    -- 应用
    ---@param result core.movement.result 结果
    o.apply = function(result)
        -- 帧后
        o.post_tick(result)
        
        ---@type table
        local children = o.children()

        children.map(
            ---@param child core.movement.handler
            function(child)
                child.apply(result)
            end
        )

        -- 是否应该结束
        if o.should_finish() then
            -- 结束
            o.on_finish()

            -- 删除
            o.delete()
        end
    end

    -- 运行
    ---@param data core.movement.data 数据
    ---@return core.movement.result
    o.run = function(data)
        -- 执行
        o.execute(data)

        ---@type core.movement.result
        local result = compute(data)

        -- 应用
        o.apply(result)

        return result
    end

    -- ()
    metatable.callable(o, o.run)

    return o
end

return g