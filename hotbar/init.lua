---@class framework.hotbar
local M = {}
package.loaded[...] = M

local reactive = require "lib.reactive"

M.PLAYER_TO_HOTBAR = {}
M.on_player_hotbar_changed = reactive.event()

---@class framework.hotbar.slot.options
---@field index integer 槽位序号
---@field key? string 当前绑定按键
---@field label? string 槽位显示名
---@field icon? any 槽位图标资源
---@field description? string 悬浮说明
---@field activate? fun(slot:framework.hotbar.slot, request?:table):any 触发槽位动作
---@field cooldown_source? skill.active 提供冷却显示的技能或对象

---@param args framework.hotbar.slot.options
---@return framework.hotbar.slot
local function create_slot(args)
    local o = reactive.factory(args)
    o.factory.set_class("framework.hotbar.slot")
    o.factory.ref_field("index", args.index)
    o.factory.ref_field("key", args.key)
    o.factory.ref_field("label", args.label or "")
    o.factory.ref_field("icon", args.icon)
    o.factory.ref_field("description", args.description or "")
    o.factory.ref_field("payload", nil)
    o.factory.ref_field("cooldown_source", args.cooldown_source)
    o.factory.event_field("on_activate")
    o.factory.event_field("on_key_down")
    o.factory.event_field("on_key_up")

    function o.assign(payload)
        payload = payload or {}
        o.payload.set(payload)
        o.label.set(payload.label or "")
        o.icon.set(payload.icon)
        o.description.set(payload.description or "")
        o.cooldown_source.set(payload.cooldown_source)
        o.activate_handler = payload.activate
        return o
    end

    function o.bind_key(key)
        o.key.set(key)
        return o
    end

    function o.activate(request)
        local result = nil
        if type(o.activate_handler) == "function" then
            result = o.activate_handler(o, request)
        elseif type(args.activate) == "function" then
            result = args.activate(o, request)
        end
        o.on_activate(request, result)
        return result
    end

    return o
end

---@class framework.hotbar.options
---@field player? player 绑定玩家
---@field owner? any 归属对象，通常是当前英雄
---@field size? integer 槽位数量

---@param args? framework.hotbar.options
---@return framework.hotbar.instance
function M.create(args)
    args = args or {}
    args.size = args.size or 1

    local o = reactive.factory(args)
    o.factory.set_class("framework.hotbar")
    o.factory.ref_field("player", args.player)
    o.factory.ref_field("owner", args.owner)
    o.factory.collection_field("slots")

    function o.get_slot(index)
        local found = nil
        o.slots().for_each(function(slot, context)
            if slot.index() == index then
                found = slot
                context.stop()
            end
        end)
        return found
    end

    function o.bind_slot(index, key)
        local slot = o.get_slot(index)
        assert(slot ~= nil, "hotbar slot not found: " .. tostring(index))
        return slot.bind_key(key)
    end

    function o.assign_slot(index, payload)
        local slot = o.get_slot(index)
        assert(slot ~= nil, "hotbar slot not found: " .. tostring(index))
        return slot.assign(payload)
    end

    function o.activate_slot(index, request)
        local slot = o.get_slot(index)
        if slot == nil then
            return nil
        end
        return slot.activate(request)
    end

    for index = 1, args.size do
        o.slots.add(create_slot({ index = index }))
    end

    if args.player ~= nil then
        M.set_for_player(args.player, o)
    end

    return o
end

---@param player player
---@param hotbar framework.hotbar.instance
function M.set_for_player(player, hotbar)
    M.PLAYER_TO_HOTBAR[player] = hotbar
    M.on_player_hotbar_changed(player, hotbar)
end

---@param player player
---@return framework.hotbar.instance?
function M.get_for_player(player)
    return M.PLAYER_TO_HOTBAR[player]
end

require ".impl"

return M
