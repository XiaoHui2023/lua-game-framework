---@class models.mod
---@operator call(...):mod
local M = {}
---@type utils.hook
local hook = require "utils.hook"
local factory = require "models.factory"

---@class mod.priority 优先级
M.PRIORITY = {
    MODELS = -100,
    NORMAL = 0,
}

---@type hook.add<mod> 模块列表
local MODS = hook.add({
    type_checker = function(element)
        return hook.is_instance_of(element,"mod")
    end,
    ---@param a mod
    ---@param b mod
    ---@return boolean? 返回值
    compare = function(a,b)
        -- 依赖
        if a.to_dependency[b] then
            return false
        end
        if b.to_dependency[a] then
            return true
        end
        return a.priority() < b.priority()
    end,
    prevent_duplicate = true,
})

-- 获取模块列表
---@return list<mod>
M.get_mods = function()
    return MODS.get()
end

-- 遍历模块
---@param func fun(mod:mod):nil
M.for_each = function(func)
    MODS.get().for_each(func)
end

---@type integer 序号
local ID = 1

---@class mod.options : factory.options
---@field name string 名称
---@field description? string 字段说明
---@field dependencies? mod[] 字段说明
---@field tags? string[] 字段说明
---@field is_enabled? boolean 字段说明
---@field is_visible? boolean 字段说明
---@field priority? integer 字段说明

-- 注册
---@param args mod.options
---@return mod
M.register = function(args)
    args.description = args.description or ""
    args.dependencies = args.dependencies or {}
    args.tags = args.tags or {}
    args.is_enabled = args.is_enabled or true
    args.is_visible = args.is_visible or false
    args.priority = args.priority or M.PRIORITY.NORMAL

    ---@class mod: factory
    local o = factory(args)
    o.set_class("mod")

    ---@type mod[] 依赖列表
    o.dependencies = args.dependencies

    ---@type table<mod, boolean> 依赖映射表
    o.to_dependency = {}
    for _, dependency in ipairs(o.dependencies) do
        o.to_dependency[dependency] = true
    end

    ---@type hook.set<integer> 优先级
    o.priority = hook.set(args.priority)

    ---@type hook.set<boolean> 使能
    o.is_enabled = hook.set(args.is_enabled)

    ---@type hook.set<boolean> 用户可见
    o.is_visible = hook.set(args.is_visible)

    ---@type hook.set<string> 描述
    o.description = hook.set(args.description)

    ---@type hook.set<boolean> 是否初始化过
    o.has_initialized = hook.set(false)

    ---@type hook.event 激活事件
    o.on_activate = hook.event()

    ---@type hook.once_event 失活删除
    o.once_deactivate = hook.once_event()

    ---@type hook.event 初始化事件
    o.on_initialize = hook.event()

    ---@type hook.computed<boolean> 是否激活
    o.is_active = hook.computed(function()
        -- 需要初始化
        if not o.has_initialized() then
            return false
        end

        -- 需要使能
        if not o.is_enabled() then
            return false
        end

        -- 需要满足依赖
        for _, dependency in ipairs(o.dependencies) do
            if not dependency.is_active() then
                return false
            end
        end

        return true
    end)

    -- 绑定初始化事件
    o.on_initialize.add(function ()
        -- 触发初始化事件
        if not o.has_initialized() then
            o.has_initialized.set(true)
        end
    end)

    -- 重载激活状态设置
    o.is_active.on_change.add(function (active)
        if active then
            -- 触发激活事件
            o.on_activate.run()
        elseif not active then
            -- 触发失活事件
            o.once_deactivate.run()
        end
    end)

    -- 绑定激活生命周期
    ---@param func fun():hook.once_event|fun():nil 生命周期函数
    o.bind_activation = function(func)
        o.on_activate.add(function ()
            o.once_deactivate.attach(func())
        end)
    end

    -- 创建帧更新计算属性
    ---@param expr fun():... 表达式
    ---@return hook.computed
    o.create_frame_update_computed = function (expr)
        ---@type hook.computed
        local computed = hook.computed(expr)

        -- 绑定到帧更新
        computed.auto_update()

        return computed
    end

    -- 依赖列表只读
    metatable.lock_new_fields(o.dependencies)
    metatable.lock_new_fields(o.to_dependency)

    ---@type integer 序号
    o.id = ID
    ID = ID + 1

    -- 添加到列表
    MODS.add(o)

    return o
end

-- ()
metatable.callable(M, M.register)

return M 
