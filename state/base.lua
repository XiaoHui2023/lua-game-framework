---@type lib.tablex
local table = require "lib.tablex"
---@class framework.state
local g = {}
local factory_model = require "lib.reactive".factory

---@class state.options: factory.options
---@field on_run? fun(context:state.context):nil 杩愯浜嬩欢

---@class state.context
---@field domain state.domain 鍩?---@field state? state 鐘舵€?---@field once_done? hook.once_event 瀹屾垚浜嬩欢
---@field target_point? point 鐩爣
---@field source? any 鏉ユ簮

-- 鍒涘缓瀵硅薄
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

    ---@type hook.set 涓婁笅鏂噑tate.context>
    o.context = o.factory.set(context)

    ---@type hook.set<boolean> 鏄惁缁撴潫
    o.is_interrupted = o.factory.set(false)

    ---@type hook.event 涓柇浜嬩欢
    o.on_interrupt = o.factory.event()

    o.on_interrupt.add(function ()
        if o.is_interrupted() then
            return
        end
        o.is_interrupted.set(true)
    end)

    return o
end

-- 缁ф壙涓婁笅鏂?---@param state state
---@return state.context
local function load_context(state)
    ---@type state.context
    local ctx = table.clone(state.domain().context())
    ctx.state = state
    return ctx
end

-- 鐘舵€?---@param args? state.options
---@return state
g.create = function (args)
    args = args or {}

    ---@class state: factory
    local o = factory_model(args)
    o.set_class("state")

    ---@type boolean 鏄惁姝ｅ湪杩愯
    local is_running = false

    ---@type boolean 鏄惁缁撴潫
    local is_finished = false

    ---@type hook.add 瀛愮姸鎬乻tate>
    o.sub_states = o.factory.add()
    o.sub_states.wrap_add(function(state)
        o.factory.capture("", state)
        return state
    end)

    ---@type hook.computed ?? state.domain>
    o.domain = o.factory.computed(function()
        ---@type state.domain?
        local parent = o.parent()
        if parent then
            return parent.domain()
        end
        return o.create_domain()
    end)

    ---@type hook.computed<boolean> 鏄惁闇€瑕佸仠姝?
    o.should_stop = o.factory.computed(function()
        ---@type state.domain
        local domain = o.domain()
        if domain.is_interrupted() then
            return true
        end
        return false
    end)

    ---@type hook.computed 绗竴涓笅绾tate?>
    o.first_sub_state = o.factory.computed(function()
        return o.sub_states().first()
    end)

    ---@type hook.computed 鏈€鍚庝竴涓笅绾tate?>
    o.last_sub_state = o.factory.computed(function()
        return o.sub_states().last()
    end)

    ---@type hook.computed 鍓嶇骇<state?>
    o.prev_state = o.factory.computed(function()
        ---@type state?
        local parent = o.parent()
        if parent then
            return parent.sub_states().prev(o)
        end
        return nil
    end)

    ---@type hook.computed 鍚庣骇<state?>
    o.next_state = o.factory.computed(function()
        ---@type state?
        local parent = o.parent()
        if parent then
            return parent.sub_states().next(o)
        end
        return nil
    end)

    ---@type hook.event 缁撴潫浜嬩欢
    o.on_finish = o.factory.event()

    -- 鍒涘缓瀵硅薄
    ---@return state.domain
    o.create_domain = function ()
        ---@type state.domain
        local domain = create_domain(o)
        o.domain.set(function ()
            return domain
        end)
        return domain
    end

    -- 鍚戝墠浼犳挱
    local function propagate_forward()
        ---@type state?
        local next_state = o.next_state()
        if next_state then
            next_state.run()
        end
    end

    -- 灏濊瘯缁撴潫
    local function try_finish()
        -- 涓嶉噸澶嶆墽琛?
        if is_finished then
            return
        end
        is_finished = true

        -- 鎵ц缁撴潫浜嬩欢
        o.on_finish()

        -- 鍚戝墠浼犳挱
        propagate_forward()
    end

    -- 鍚戜笅浼犳挱
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

        -- 娌℃湁涓嬬骇锛岀洿鎺ヤ紶閫?        try_finish()
    end

    -- 杩愯
    o.run = function ()
        -- 闇€瑕佸仠姝?
        if o.should_stop() then
            return
        end
        -- 涓嶉噸澶嶆墽琛?
        if is_running then
            return
        end
        is_running = true

        -- 鎵ц杩愯浜嬩欢
        if o.on_run then
            ---@type hook.once_event 瀹屾垚
            local once_done = o.factory.once_event()
            ---@class state.context
            local ctx = load_context(o)
            ctx.once_done = once_done
            o.on_run(ctx)
            once_done.add(propagate_down)
            return
        end

        -- 娌℃湁杩愯浜嬩欢锛岀洿鎺ヤ紶閫?        propagate_down()
    end

    -- 鎵撴柇
    ---@return boolean 鏄惁鎴愬姛鎵撴柇
    o.interrupt = function ()
        -- 瑙﹀彂涓柇浜嬩欢
        o.on_interrupt()

        -- 瑙﹀彂涓嬬骇涓柇浜嬩欢
        o.sub_states().for_each(function (child)
            child.interrupt()
        end)

        -- 瑙﹀彂鍚庣骇鎵撴柇浜嬩欢
        ---@type state?
        local next = o.next_state()
        if next then
            next.interrupt()
        end

        -- 鍒犻櫎鑷繁
        o.delete()

        return true
    end

    -- 鏋勫缓鏍?    ---@param tree state.tree
    o.build_tree = function (tree)
        g.build_tree(tree,o)
    end

    return o
end

---@class state.tree.options : state.options
---@field key state.key 妯℃澘閿?
---@alias state.tree (state.options[]|state.tree[])

-- 鏋勫缓鐘舵€佹爲
---@param tree state.tree
---@param parent? state 鐖剁姸鎬?---@return state state
g.build_tree = function (tree, parent)
    -- 鏋勫缓涓€鐐?    ---@param tree_level state.tree
    ---@param parent? state 鐖剁姸鎬?    ---@return state
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

-- 閫氳繃閿幏鍙栫敓鎴愬櫒
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
