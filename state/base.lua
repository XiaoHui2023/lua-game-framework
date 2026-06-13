---@class models.state
local g = require ".base"
local factory_model = require "models.factory"

---@class state.options: factory.options
---@field on_run? fun(context:state.context):nil 运行事件

---@class state.context
---@field domain state.domain 域
---@field state? state 状态
---@field once_done? hook.once_event 完成事件
---@field target_point? point 目标点
---@field source? any 来源

-- 创建域
---@param state state
---@return state.domain
local function create_domain(state)
    ---@class state.domain:factory
    local o = factory_model({
        parent = state,
    })
    o.set_class("state.domain")

    ---@class state.context
    local context = {
        domain = o,
    }

    ---@type hook.set 上下文<state.context>
    o.context = o.factory.set(context)

    ---@type hook.set 是否结束了<boolean>
    o.is_interrupted = o.factory.set(false)

    ---@type hook.event 中断事件
    o.on_interrupt = o.factory.event()

    o.on_interrupt.add(function ()
        if o.is_interrupted() then
            return
        end
        o.is_interrupted.set(true)
    end)

    return o
end

-- 继承上下文
---@param state state
---@return state.context
local function load_context(state)
    ---@type state.context
    local ctx = table.clone(state.domain().context())
    ctx.state = state
    return ctx
end

-- 状态
---@param args? state.options
---@return state
g.create = function (args)
    args = args or {}

    ---@class state: factory
    local o = factory_model(args)
    o.set_class("state")

    ---@type boolean 是否正在运行
    local is_running = false

    ---@type boolean 是否结束了
    local is_finished = false

    ---@type hook.add 子状态<state>
    o.sub_states = o.factory.add()

    ---@type hook.computed 域<state.domain>
    o.domain = o.factory.computed(function()
        ---@type state.domain?
        local parent = o.parent()
        if parent then
            return parent.domain()
        end
        return o.create_domain()
    end)

    ---@type hook.computed 是否需要停止<boolean>
    o.should_stop = o.factory.computed(function()
        ---@type state.domain
        local domain = o.domain()
        if domain.is_interrupted() then
            return true
        end
        return false
    end)

    ---@type hook.computed 第一个下级<state?>
    o.first_sub_state = o.factory.computed(function()
        return o.sub_states().first()
    end)

    ---@type hook.computed 最后一个下级<state?>
    o.last_sub_state = o.factory.computed(function()
        return o.sub_states().last()
    end)

    ---@type hook.computed 前级<state?>
    o.prev_state = o.factory.computed(function()
        ---@type state?
        local parent = o.parent()
        if parent then
            return parent.children().prev_state(o)
        end
        return nil
    end)

    ---@type hook.computed 后级<state?>
    o.next_state = o.factory.computed(function()
        ---@type state?
        local parent = o.parent()
        if parent then
            return parent.children().next_state(o)
        end
        return nil
    end)

    ---@type hook.event 结束事件
    o.on_finish = o.factory.event()

    -- 创建域
    ---@return state.domain
    o.create_domain = function ()
        ---@type state.domain
        local domain = create_domain(o)
        o.domain.set(function ()
            return domain
        end)
        return domain
    end

    -- 向前传播
    local function propagate_forward()
        ---@type state?
        local next_state = o.next_state()
        if next_state then
            next_state.run()
        end
    end

    -- 尝试结束
    local function try_finish()
        -- 不重复执行
        if is_finished then
            return
        end
        is_finished = true

        -- 执行结束事件
        o.on_finish()

        -- 向前传播
        propagate_forward()
    end

    -- 向下传播
    local function propagate_down()
        ---@type state?
        local first_sub_state = o.first_sub_state()
        if first_sub_state then
            first_sub_state.run()

            ---@type state?
            local last_sub_state = o.last_sub_state()
            assert(last_sub_state)
            last_sub_state.on_finish.add(try_finish)

            return
        end

        -- 没有下级，直接传播
        try_finish()
    end

    -- 运行
    o.run = function ()
        -- 需要停止
        if o.should_stop() then
            return
        end
        -- 不重复执行
        if is_running then
            return
        end
        is_running = true

        -- 执行运行事件
        if o.on_run then
            ---@type hook.once_event 完成
            local once_done = o.factory.once_event()
            ---@class state.context
            local ctx = load_context(o)
            ctx.once_done = once_done
            o.on_run(ctx)
            once_done.add(propagate_down)
            return
        end

        -- 没有运行事件，直接传播
        propagate_down()
    end

    -- 打断
    ---@return boolean 是否成功打断
    o.interrupt = function ()
        -- 触发中断事件
        o.on_interrupt()

        -- 触发下级中断事件
        o.children().for_each(function (child)
            child.interrupt()
        end)

        -- 触发后级打断事件
        ---@type state?
        local next = o.next()
        if next then
            next.interrupt()
        end

        -- 删除自己
        o.delete()

        return true
    end

    -- 构建树
    ---@param tree state.tree
    o.build_tree = function (tree)
        g.build_tree(tree,o)
    end

    return o
end

---@class state.tree.options : state.options
---@field key state.key 模板键

---@alias state.tree (state.options[]|state.tree[])

-- 构建状态树
---@param tree state.tree
---@param parent? state 父状态
---@return state state
g.build_tree = function (tree, parent)
    -- 构建一层
    ---@param tree_level state.tree
    ---@param parent? state 父状态
    ---@return state
    local function build_level(tree_level,parent)
        if not parent then
            parent = g.create()
        end

        for _, e in ipairs(tree_level) do
            local is_tree = #e > 0
            if is_tree then
                ---@cast e state.tree
                local sub = build_level(e)
                parent.sub_states.add(sub)
            else
                ---@cast e state.tree.options
                local key = e.key
                local generator = g.get_generator_by_key(key)
                local state = generator(e)
                parent.sub_states.add(state)
            end
        end

        return parent
    end
    return build_level(tree,parent)
end

-- 通过键获取生成器
---@param key state.key
---@return fun(options: state.options): state
g.get_generator_by_key = function (key)
    local generator = g[key]
    if not generator then
        error("state template not found: " .. key)
    end
    return generator
end

return g